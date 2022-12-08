---------------------------------------------------------------------------
-- Title:	Object Detection and Tracking Algorithm Tool
-- Desc.:	This tool reads in APRD radar data files and detects
		-- and tracks moving objects within the data. It calculates
		-- the range and bearing angle of a signle object in each 
		-- scan. It is originally intended for use with the UAV 
		-- collision avoidance and satellite vehicle awareness
		-- programs. It is written for use with APRD v12.10 r7 and
		-- later.	
-- Usage:	The tool reads the data set that is currently loaded into
		-- APRD. The data must have been created with a configuration 
		-- of at least 3 sensors. Sensor 0 should be the only transmitting
		-- sensor with sensors 1 and 2 recieve only. To generate data
		-- the user can either collect using a physical system, or can
		-- use the Simulation Data Generation tool.
-- Author:	Patton Gregg
-- Rev.:	v0.2, 7/31/2009
----------------------------------------------------------------------------

L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
CM = complex_matrix
M = matrix
V = vector
WM = window_manager
DT = data_tape

c = 299792458
-- min distance scale factor such that sin(theta) ~= theta by min tolerance of 0.001 radians
min_d_det_scale_factor = 5.6 

function file_exists(filename)
	
	local valid = true
	local file_ptr, err = io.open(filename, "r")
	
	if err then
		valid = false
	end
	
	return valid
end

function verify(params)

	local no_errors = true
	
	if params.read_file == true then
		if (file_exists(params.sim_data_file) == false) then
			forms.error("Specified Simulation Data File Does Not Exist!")
			no_errors = false
		end
	end
	
	return no_errors
end

function get_combo_tape (tape, tx, rx) return tape[function (x) return x.TX == tx and x.RX == rx end] end

-- BEARING ANGLE DETERMINATION
function bearing_ang_calc(l_resp, r_resp)

	-- Determine the difference in phase angles between the two receiving sensors
	-- unwrap gives you the distance for associated with the difference in phase angles
	local phase_ang_diff = M.unwrap(CM.arg(l_resp) - CM.arg(r_resp))
	
	-- The slope of da gives you the distance
	local da = V(#phase_ang_diff)
	for i = 1, #phase_ang_diff do
		da[i], b = V.linear_regress(phase_ang_diff[i])
	end
	
	-- Scale da by the distance between the sensors so that you can take asin of alpha
	-- such that opposite = da and adjacent = (2 * PI * freq_step * T_cross)
	local alpha = da / (2 * PI * freq_step * T_cross)

	-- Bearing angles in radians and degrees
	local b_rad = V.asin(alpha)
	local b_deg = b_rad * (180 / PI)

	return b_rad, b_deg
end

-- TARGET RANGE DETERMINATION
function range_calc(l_resp, r_resp)

	local range_l = CM.fft(l_resp, params.nFFT, true, true)
	local range_r = CM.fft(r_resp, params.nFFT, true, true)

	local range_l_max_i = V(#range_l)
	local range_r_max_i = V(#range_r)

	-- range_l_max_i = M.max(CM.abs(range_l))
	-- range_r_max_i = M.max(CM.abs(range_r))

	for i = 1, #range_l do
		temp1, range_l_max_i[i] = V.max(CV.abs(range_l[i]))
		temp2, range_r_max_i[i] = V.max(CV.abs(range_r[i]))
	end

	local range_l_max = range_l_max_i * (R_max/params.nFFT)
	local range_r_max = range_r_max_i * (R_max/params.nFFT)

	local range_avg = ( range_l_max + range_r_max ) / 2

	return range_avg, range_l_max, range_r_max
end

function target_track_calc(range_avg, bearing_rad)

	target_track_polar = CV.polar(range_avg, bearing_rad)

	target_track = M(2, #range_avg)
	target_track[1] = range_avg * V.cos(bearing_rad)
	target_track[2] = range_avg * V.sin(bearing_rad)

	target_track = M.transpose(target_track)

	return target_track_polar, target_track
end

-- Change in bearing angle between scans
function delta_bearing_calc (bearing_rad)

	local delta_bearing = V.slice(bearing_rad, 1, #bearing_rad-1) - V.slice(bearing_rad, 2, #bearing_rad)
	local delta_bearing_deg = delta_bearing * (180 / PI)
	
	return delta_bearing, delta_bearing_deg
end

-- Threshold for determining if an avoidance manuever is needed
function bearing_thres_calc (bearing_rad, range_avg) 

	local temp_numer = V.slice(range_avg, 1, #range_avg-1) - V.slice(range_avg, 2, #range_avg)
	local temp_demon = V.slice(range_avg, 1, #range_avg-1) * V.slice(range_avg, 2, #range_avg)
	local deltaBearingThres = params.min_d * (temp_numer/temp_demon)
	local deltaBearingThres_deg = deltaBearingThres * (180 / PI)

	return deltaBearingThres, deltaBearingThres_deg
end 

function zero_peak_sig (freq_data)

	local time_resp_win_abs = CM.abs(CM.fft(freq_data, params.nFFT, true, true))
	local time_resp = CM.fft(freq_data, params.nFFT, false, true)
	
	local peak_val = V(#time_resp_win_abs)
	local peak_i = V(#time_resp_win_abs)
	for i = 1, #time_resp_win_abs do
		peak_val[i], peak_i[i] = V.max(time_resp_win_abs[i])
	end

	-- Find the indices for the boundaries of the largest peak
	-- local i_min = V(peak_i+1)
	-- local i_max = V(peak_i+1)
	local i_min = V(#peak_i)
	local i_max = V(#peak_i)
	for i = 1, #time_resp_win_abs do
		peak_left_deltas = V.reverse(V.slice(time_resp_win_abs[i], 2, peak_i[i])) - V.reverse(V.slice(time_resp_win_abs[i], 1, peak_i[i]-1))
		peak_right_deltas = V.slice(time_resp_win_abs[i], peak_i[i]+1, params.nFFT-1) - V.slice(time_resp_win_abs[i], peak_i[i]+2, params.nFFT)
		
		i_min[i] = peak_i[i] - find_bound_i(peak_left_deltas)
		i_max[i] = peak_i[i] + find_bound_i(peak_right_deltas)
		print("i_min[i], peak_i[i], i_max[i]", i_min[i], peak_i[i], i_max[i])
	end
	
	local new_time_resp = CM()
	for j = 2, #time_resp do
		local new_cv = CV(CV.slice(time_resp[j], 1, i_min[j]))
		new_cv = CV.append(new_cv, CV((i_max[j]-1) - (i_min[j]+1), 0))
		-- new_cv = CV.append(new_cv, CV((i_max[j]-1) - (i_min[j]+1), time_resp[i_min[j]+1], (time_resp[i_max[j]-1]-time_resp[i_min[j]+1])/(i_max[j]-1) - (i_min[j]+1)))
		-- new_cv = CV.append(new_cv, CV.slice(time_resp[j], i_min[j]+1, i_max[j]-1) - CV.slice(time_resp[j-1], i_min[j]+1, i_max[j]-1))
		new_cv = CV.append(new_cv, CV.slice(time_resp[j], i_max[j], #time_resp[j]))
		CM.append(new_time_resp, new_cv)
	end
	
	local scans = CM.fft(new_time_resp, params.nFFT, false, false)
	scans = CM.reverse(scans)
	print("scans", scans)
	
	return scans
end

function find_bound_i(v)
	
	local i = 1
	
	while (v[i] > 0 and i < #v) do i = i + 1 end

	return i
end

function gen_plot (plot_type_str, plot_label_str, data_v, data_label_str, x_label, y_label, plot_prop) 
	local chart_plot = P(plot_type_str, plot_label_str, data_v, data_label_str)
	chart.set_xlabel(chart_plot, x_label)
	chart.set_ylabel(chart_plot, y_label)
	chart.set_property(chart_plot, plot_prop)
	chart.update(chart_plot)
	
	return range_plot
end

dofile("LuaProg/Tool-Target-Det-Dialog.lua")
params = get_parameters()
if params == nil then error() end

t0 = system.get_UTC_time()

-- Read data
if params.read_file == true then
	tape = DT.read(params.sim_data_file)
else
	tape = data_source.get_tape()
	if (#tape == 0) then
		forms.error("No data! Please specify or load a data file.")
	end
end

n_pts, F0, F1, SR = DT.get_scan_parameters(tape)
print("n_pts, F0, F1, SR", n_pts, F0, F1, SR)
freq_step = DT.get_freq_step(tape)*1e6; print("freq_step", freq_step)

SL = data_tape.get_sensor_table(tape)
dist_rx = math.sqrt((SL[2].X-SL[3].X)^2+(SL[2].Y-SL[3].Y)^2)

R_max = c / (2 * freq_step)
T_cross = dist_rx / c

-- Read the left and right antenna data from the sensors 2 and 3 respectively
tapeL = get_combo_tape(tape, 1, 2)
tapeR = get_combo_tape(tape, 1, 3)

-- Determine how many scans to use and extract matrices
num_scans = math.min(#tapeL, #tapeR); print("num_scans", num_scans)
dT = tapeR[2].TIMESTAMP - tapeR[1].TIMESTAMP; print("dT", dT)

tapeL = data_tape.slice(tapeL, 1, num_scans)
tapeR = data_tape.slice(tapeR, 1, num_scans)

cmL = data_tape.get_matrix(tapeL)
cmR = data_tape.get_matrix(tapeR)

cmL = CM.slice(cmL, 2, #cmL) - CM.slice(cmL, 1, #cmL - 1)
cmR = CM.slice(cmR, 2, #cmR) - CM.slice(cmR, 1, #cmR - 1)

bearing_rad, bearing_deg = bearing_ang_calc(cmL, cmR)

print("\nTarget Bearing Angle (deg)")
L.display(bearing_deg)

range_avg, range_l, range_r = range_calc(cmL, cmR)

print("\nTarget Range (m)")
L.display(range_avg)

-- Use transmit sensor in monostatic mode to allow for target triangulation
-- Determines if the transmit sensor is used as a monostatic receiver
-- Using the tx as an 3rd rx offset in the y-direction allows for determination
-- of whether the object is in-front or behind the sensor
if (DT.is_valid_combination(tape, 1, 1) == true) then
	tapeTX = get_combo_tape(tape, 1, 1)
	tapeTX = data_tape.slice(tapeTX, 1, num_scans)
	cmTX = data_tape.get_matrix(tapeTX)	

	range_tx = CM.fft(cmTX, params.nFFT, true, true)

	range_tx_peak_i = V(#range_tx)
	range_tx_peak = V(#range_tx)

	for i = 1, #range_tx do
		temp1, range_tx_peak_i[i] = V.max(CV.abs(range_tx[i]))
	end

	range_tx_peak = range_tx_peak_i * (R_max/params.nFFT)

	for i = 1, #bearing_rad do
		if range_tx_peak[i] < range_avg[i] then
			bearing_rad[i] = bearing_rad[i] - PI/2
		else
			bearing_rad[i] = -bearing_rad[i] + PI/2
		end
	end
else

	bearing_rad = -bearing_rad + PI/2
end

target_track_polar, target_track = target_track_calc(range_avg, bearing_rad)

print("\nTarget Location (m)")
L.display(target_track)

-- BEARING THRESHOLD AND MANUEVER CALCULATIONS

delta_bearing, delta_bearing_deg = delta_bearing_calc(bearing_rad)

delta_bearing_thres, delta_bearing_thres_deg = bearing_thres_calc(bearing_rad, range_avg)

diff_b = V.abs(delta_bearing_thres_deg) - V.abs(delta_bearing_deg)

-- DETERMINE IF COLLISION SCENARIO

close_v = (V.slice(range_avg, 1, #range_avg-1) - V.slice(range_avg, 2, #range_avg)) / dT

-- IF the following is true, then determine this as a collision scenario
	-- The bearing angle change is lower than the change threshold
	-- AND we haven't set the flag for an avoidance manuever
	-- AND the range is far enough so we can make a good calculation for the bearing angle change threshold
avoid = false
for i = 1, #diff_b do
	if (diff_b[i] > 0 and close_v[i] > 0 and avoid == false and range_avg[i+1] > min_d_det_scale_factor*params.min_d) then
		avoid = true
		rel_v = close_v[i]
		
		if delta_bearing[i] > 0 then
			avoid_ang = (bearing_deg[i+1] - 90)
		else
			avoid_ang = (bearing_deg[i+1] + 90)
		end
		
		t_avoid = range_avg[i+1] / close_v[i]
		range_det = range_avg[i+1]
		delta_v = params.min_d / t_avoid
	end
end

print("\nTotal Run Time", system.get_UTC_time() - t0)

-- PLOT RESULTS

if (params.realtime == true) then
	for i = 1, num_scans do
		t_start = system.get_UTC_time()
		
		-- P("P", "Ang Profile", CV.abs(ang_prof[i]))
		
		if (params.range_plot == true) then
			range_plot = gen_plot("RANGE", "Range vs Scan", V.slice(range_avg, 1, i), "Range to Object", "Scan Number", "Range (m)", SCATTER_LINE) 
		end

		if (params.bear_ang_plot == true) then
			ba_plot = gen_plot("BEAR_ANG", "Bearing Angle vs Time", V.slice(bearing_deg, 1, i), "Bearing Angle", "Scan Number", "Degrees", SCATTER_LINE)
		end

		if (params.delta_plot == true) then
			delta_bearing_p = P("BEAR_ANG_DELTA", "Bearing Angle Delta Threshold", 
				{V.slice(V.abs(delta_bearing_deg), 1, i), "Bearing Angle Change Between Scans"},
				{V.slice(V.abs(delta_bearing_thres_deg), 1, i), "Bearing Angle Change Threshold", "(Determines Collision Scenario)"} )
			chart.set_ylabel(delta_bearing_p, "Degrees")
			chart.set_xlabel(delta_bearing_p, "Scan Number")
			chart.set_property(delta_bearing_p, SCATTER_LINE)
			chart.update(delta_bearing_p)
		end
			
		if (params.object_plot == true) then
			object_field = P("OBJECT_FIELD", "Object Tracking Field",
				{CV.slice(target_track_polar, 1, i), "Object Track"},
				{CV.polar(V(90, params.min_d), V(90, 0, (2*PI)/90)), "Minimum Distance", params.min_d .. "m"} )
			chart.set_xlabel(object_field, "Meters")
			chart.set_ylabel(object_field, "Meters")
			chart.set_property(object_field, SCATTER_LINE)
			chart.update(object_field)
		end
		
		if (params.status_win == true) then
			w = WM.make(FL_TEXT_WINDOW, "STATUS WINDOW")
			if (avoid == true) then
				t = {
					" - SIMULATION STATUS - ",
					"*",
					string.format("Simulation Time: %.2f s", dT*i),
					"*",
					" - COLLISION DETECTION STATUS - ",
					"*",
					"Collision Threat Detected!",
					"*",
					string.format("Range at Detection: %.1f m", range_det),
					string.format("Closing Velocity at Detection: %.1f m\\s", rel_v),
					string.format("Time for Avoidance at Detection: %.1f s", t_avoid),
					string.format("Avoidance Angle: %.1f deg", avoid_ang),
					string.format("Delta V (Instantaneous Thrust): %.2f m\\s", delta_v),
					string.format("Time Until Collision: %.2f s", range_avg[i]/close_v[i]),	
						
					"*",
					" - DETECTED OBJECT STATUS - ",
					"*",
					string.format("Range: %.2f m", range_avg[i]),
					string.format("Bearing Angle: %.2f deg", bearing_deg[i]),
					string.format("Relative Velocity: %.2f m\\s", close_v[i]),
				}
			else
				t = {
					" - SIMULATION STATUS - ",
					"*",
					string.format("Simulation Time: %.2f s", dT*i),	
					"*",
					" - COLLISION DETECTION STATUS - ",
					"*",
					"No Collision Threat Detected",
					"*",
					" - DETECTED OBJECT STATUS - ",
					"*",
					string.format("Range: %.2f m", range_avg[i]),
					string.format("Bearing Angle: %.2f deg", bearing_deg[i]),
					string.format("Relative Velocity: %.2f m\\s", close_v[i]),	

				}
			end
			
			WM.update(w, t)
		end
		
		while (system.get_UTC_time() - t_start < dT) do end
	end
else
	if (params.range_plot == true) then
		range_plot = gen_plot("RANGE", "Range vs Scan", range_avg, "Range to Object", "Scan Number", "Range (m)", SCATTER_LINE) 
	end

	if (params.bear_ang_plot == true) then
		ba_plot = gen_plot("BEAR_ANG", "Bearing Angle vs Time", bearing_deg, "Bearing Angle", "Scan Number", "Degrees", SCATTER_LINE)
	end

	if (params.delta_plot == true) then
		delta_bearing_p = P("BEAR_ANG_DELTA", "Bearing Angle Delta Threshold", 
			{V.abs(delta_bearing_deg), "Bearing Angle Change Between Scans"},
			{V.abs(delta_bearing_thres_deg), "Bearing Angle Change Threshold", "(Determines Collision Scenario)"} )
		chart.set_ylabel(delta_bearing_p, "Degrees")
		chart.set_xlabel(delta_bearing_p, "Scan Number")
		chart.set_property(delta_bearing_p, SCATTER_LINE)
		chart.update(delta_bearing_p)
	end
		
	if (params.object_plot == true) then
		object_field = P("OBJECT_FIELD", "Object Tracking Field", 
			{target_track_polar, "Object Track"},
			{CV.polar(V(90, params.min_d), V(90, 0, (2*PI)/90)), "Minimum Distance", params.min_d .. "m"} )
		chart.set_xlabel(object_field, "Meters")
		chart.set_ylabel(object_field, "Meters")
		chart.set_property(object_field, SCATTER_LINE)
		chart.update(object_field)
	end
	
	if (params.status_win == true) then
		w = WM.make(FL_TEXT_WINDOW, "STATUS WINDOW")
		if (avoid == true) then
			t = {
				"*",
				"Collision Threat Detected!",
				"*",
				string.format("Object Closing Velocity: %.1f m\\s", rel_v),
				string.format("Range at Detection: %.1f m", range_det),
				string.format("Avoidance Angle: %.1f deg", avoid_ang),
				string.format("Time for Avoidance: %.1f s", t_avoid),
				string.format("Delta V (Instantaneous Thrust): %.2f m\\s", delta_v),		
			}
		else
			t = {
				"*",
				"No Collision Threat Detected",
			}
		end
		WM.update(w, t)
	end
end

-- TRY THE FFT METHOD FOR BEARING ANGLE CALCULATION

function find_ba_peak_i (ang_prof)
	local max_ang_i = V(#ang_prof)
	for i = 1, #ang_prof do
		temp1, max_ang_i[i] = V.max(CV.abs(ang_prof[i]))
		if max_ang_i[i] > #ang_prof[i] / 2 then
			max_ang_i[i] = max_ang_i[i] - #ang_prof[i]
		end
	end	

	return max_ang_i
end

-- print("\nmax_ang_i")
-- L.display(max_ang_i)
function gen_ba_bin_table (max_ang_i, bearing_deg)
	local ang_bin_range_table = M()
	local ang_bin_table_entry = V(3)
	for i = 1, #max_ang_i do
		if (i == 1) then
			ang_bin_table_entry[1] = max_ang_i[i]
			ang_bin_table_entry[2] = bearing_deg[i]
		elseif (max_ang_i[i] ~= max_ang_i[i-1]) then
			ang_bin_table_entry[3] = bearing_deg[i-1]
			M.append(ang_bin_range_table, ang_bin_table_entry)

			ang_bin_table_entry[1] = max_ang_i[i]
			ang_bin_table_entry[2] = bearing_deg[i]
		end
	end
	ang_bin_table_entry[3] = bearing_deg[#max_ang_i]
	M.append(ang_bin_range_table, ang_bin_table_entry)
	
	local ang_bin_range_avg = M()
	
	for i = 1, #ang_bin_range_table do
		local temp_entry = V(2)
		temp_entry[1] = ang_bin_range_table[i][1]
		temp_entry[2] = (ang_bin_range_table[i][2] + ang_bin_range_table[i][3]) / 2
		M.append(ang_bin_range_avg, temp_entry)
	end
	
	return ang_bin_range_table, ang_bin_range_avg
end

function map_ba_deg (max_ang_i, ang_bin_range_avg)
	local ba_deg = V(#max_ang_i)
	
	for j = 1, #max_ang_i do
		found = false
		k = 1
		while (found == false and k <= #ang_bin_range_avg) do
			if (max_ang_i[j] == ang_bin_range_avg[k][1]) then
				found = true
				ba_deg[j] = ang_bin_range_avg[k][2]				
			else
				k = k + 1
			end
		end
	end
	
	return ba_deg
end

-- ang_prof = CM.fft(cmL * CM.conj(cmR), params.nFFT, false, true)
ang_prof = CM()
for i = 1, #cmL do
	CM.append(ang_prof, CV.fft(cmL[i] * CV.conj(cmR[i]), params.nFFT, false, true))
end

-- P("P", "Ang Profile", CV.abs(ang_prof[1]))

max_ang_i = find_ba_peak_i(ang_prof)
ang_bin_range_table, ang_bin_range_avg = gen_ba_bin_table(max_ang_i, bearing_deg)
ba_deg = map_ba_deg(max_ang_i, ang_bin_range_avg)


angle_bin_range_max = 0
angle_bin_range_min = 180
for i = 1, #ang_bin_range_table do
	angle_bin_range = math.abs(ang_bin_range_table[i][2] - ang_bin_range_table[i][3])
	if (angle_bin_range_max < angle_bin_range) then
		angle_bin_range_max = angle_bin_range
	end
	
	if (angle_bin_range_min > angle_bin_range) then
		angle_bin_range_min = angle_bin_range
	end
end

print("\nAngle Index Mapping Table")
L.display(ang_bin_range_table)

print("\nAngle Index Average")
L.display(ang_bin_range_avg)

print("\nAngle Bin Range Min. (deg)", angle_bin_range_min)
print("Angle Bin Range Max. (deg)", angle_bin_range_max)
-- -- diff_ranges = range_l - range_r

ba_plot2 = gen_plot("BEAR_ANG2", "Bearing Angle vs Time (FFT Method)", ba_deg, "Bearing Angle", "Scan Number", "Degrees", SCATTER_LINE)
