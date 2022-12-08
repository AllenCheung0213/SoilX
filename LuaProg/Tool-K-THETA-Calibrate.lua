--
-- Tool-K-THETA-Calibration
--

Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

dofile("LuaProg/UTIL-Header.lua")

RP = radar_program

---------------------------------------------------------------------------------------
NP, F0, F1 = DS.get_scan_parameters()
print(NP, F0, F1)

---------------------------------------------------------------------------------------
SL = config.get_sensor_table()

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
itrial = 4096
use_average_values = false
generate_plots = true

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function consolidate_tape(tape)
	
	m = M()
	for i = 1, #SL do
		M.append(m, DT.find(tape, function(S) return S.RX == i end))
	end

	cm = CM()
	for i = 1, #SL do
		CM.append(cm, CM.avg(DT.get_matrix(tape[m[i]])))
	end

	return cm
end

---------------------------------------------------------------------------------------
function get_average_matrix(nframe)

	-- Since we average K and theta, calibration is 
	-- independent of stitch points.
	DS.remove_stitch_point(true)

	-- This prevents the system from normally attempting
	-- to read a nulling file and send it to the radar.
	RP.enable_nulling_calibration(true)

	-- This causes the radar program to assemble the
	-- correct protocol.
	config().DATA_NULLING = true

	-- This initializes the data source and programs
	-- the radar.
	DS.set_type(HARDWARE)
	DS.reset()

	-- We can collect all the data we want with a 
	-- single call to the data source.
	local tape = DS.collect(nframe, SINGLE_FRAME)

	-- Put everything back the way it was.
	RP.enable_nulling_calibration(false)

	config().DATA_NULLING = false

	return consolidate_tape(DT.slice(tape,  0.90 * #tape))
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------

-- Sends a nulling table to all radar.
function send_nulling_table(T)

	CL = config.get_combo_table()

	m = CM(#CL, #T)
	for i = 1, #CL do
		m[i] = T
	end

	RP.send_nulling_matrix(m)
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function plot_matrix(m, t1, t2)

print(m, t1, t2)
	
	-- Need this for frequency plots.
	local fvector = V(NP, F0, DS.get_freq_step())

	local w = chart(t1, t1, FL_CHART_WINDOW)

	chart.set_xlabel(w, "Frequency (MHz)")
	chart.set_ylabel(w, "Magnitude (dB)")

	chart.clear(w)
	for i = 1, #m do
		chart.add(w, fvector, CV.dec(m[i]), t1, t2)
	end
	chart.update(w)
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function calculate_K_Theta(S, S0, S1)

	local dS = S1 - S0; 
	
	local P = CV.arg(dS)
	local K = CV.abs(dS) / itrial

	-- Calculate average K and Theta values.
	local P = V.sum(P) / #P
	local K = V.sum(K) / #K

	-- Adjust K for the current gain setting.
	local K = 1.0 / (2^(S.GAIN / 2) * K)

	return K, P

end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function get_calibration(nframe)

	-- 1st time around, we want to get an average scan based upon a zero-filled
	-- nulling table

	-- make the table
	local N0 = CV(NP)

	-- send it
	send_nulling_table(N0)

	local M0 = get_average_matrix(nframe)

	if generate_plots then
		plot_matrix(M0, "S0", "Table = 0")
	end

	-- 2nd time around, we want to get an average scan based upon an 'identity'
	-- nulling table.  itrial represents the mid-point in the dynamic range.

	-- make the table
	local N1 = CV(NP, itrial)

	-- send it
	send_nulling_table(N1)

	local M1 = get_average_matrix(nframe)

	if generate_plots then
		plot_matrix(M1, "S1", string.format("Table = %d", itrial))
	end

	if generate_plots then
		plot_matrix(M1 - M0, "dS = S1 - S0", "")
	end
	
	---------------------------------------------------------------------------------------
	---------------------------------------------------------------------------------------
	-- Now we can calculate K and Theta for each sensor.
	local K = V()
	local P = V()
	for i = 1, #SL do

		local _k, _theta

		if SL[i].RX then
			_k, _theta = calculate_K_Theta(SL[i], M0[i], M1[i])
		else
			_k, _theta = 1.0, 0.0
		end

		V.append(K, _k)
		V.append(P, _theta);
	end

	L.display("K", K)
	L.display("Theta", P)

	return K, P
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function plot_diagnostic_matrix(m, name)
	local _m = matrix.transpose(m)
	local c = chart(name, FL_CHART_WINDOW)
	chart.clear(c)
	for i = 1, #_m do
		chart.add(c, V(#_m[i],1,1), _m[i], SL[i].IP)
	end
	chart.update(c)
end

---------------------------------------------------------------------------------------
function do_diagnostic(m, n)
	local Km = matrix()
	local Pm = matrix()
	for i = 1, n do
		local K, P = get_calibration(m)
		matrix.append(Km, K)
		matrix.append(Pm, P)
		file.write_matrix("Km.txt", Km)
		file.write_matrix("Pm.txt", Pm)
		plot_diagnostic_matrix(Km, "Km")
		plot_diagnostic_matrix(Pm, "Pm")
	end
end

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function do_calibration(n)

	local msg = string.format("%2s %-13s %5s %10s %10s\n", "#", "IP", "Port", "K", "Theta")

	local K, P = get_calibration(n)
	for i = 1, #SL do
		msg = msg .. string.format("%2d %13s %5s %10.3f %10.3f\n", i - 1, SL[i].IP, SL[i].PORT, K[i], P[i])
	end

	answer = forms.yes_no(msg .. "\nUpdate Hardware/Sensor Parameters?")
	if answer == IDYES then
		for i = 1, #SL do
			SL[i].NULLING_K = K[i]
			SL[i].NULLING_THETA = P[i]
		end
		config.set_sensor_table(SL)
	end
end

if true then
	do_calibration(128)
else
	do_diagnostic(100, 20)
end

