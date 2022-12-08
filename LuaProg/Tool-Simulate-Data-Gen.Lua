VERSION =  "0.9.3b, 02/04/2011"
-- Title: Radar Data Simulation Generation
-- Filename: Tool-Simulate-Data-Gen
-- Description: Generates radar data from a given set up scenario parameters
-- Author: Patton Gregg
-- Revision History:
--	0.9.3b, 02/08/2011
--		Added option to specifiy Power of R as 0 (no distance correction)
--	0.9.3, 02/04/2011
--		Added ability to output file directly to disk
--	0.9.2, 01/20/2011
--		Added ability to simulate breathing targets
--	0.9.1, 01/14/2011
-- 		Fixed some bugs in calculating the target distance and in getting the target response
--	0.9.0, 12/21/2010
--		Beta version

--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-File.lua")
dofile("LuaProg/Lib-Radar.lua")
dofile("LuaProg/Lib-Table.lua")
--------------------------------------------------------

-------------------------------------------------------

function verify(params)

	local no_errors = true
	
	if params.noise == true then
		if (FileExists(params.noise_filename) == false) then
			forms.error("Invalid Noise Background File!")
			no_errors = false
		end
	end
	
	-- rcs_pow defaults to 1
	rcs_pow = 1
	if params.pow_r == 0 then
		rcs_pow = 1
	elseif params.pow_r == 1 then
		rcs_pow = -1
	elseif params.pow_r == 1.5 then
		rcs_pow = -0.5
	elseif params.pow_r == 2 then
		rcs_pow = 0
	elseif params.pow_r == 3 then
		rcs_pow = 0.5
	elseif params.pow_r == 4 then
		rcs_pow = 1
	else
		forms.error("Please specify 'Power of R' as: 1, 1.5, 2, 3, or 4")
	end
	
	return no_errors
end

dofile("LuaProg/Tool-Simulate-Data-Gen-Dialog.lua")
params = get_parameters()
if params == nil then error() end

if params.noise == true then
	noise_tape = data_tape.read(params.noise_filename)
	bg_noise_cv = noise_tape[1].DATA
	-- L.display(bg_noise_cv)
end

nFFT = 16384	-- debug only
tape = DS.get_tape() ; DT.clear(tape)
c = 299792458

-------------------------------------------------------
nFRQ, F0, F1, SRate = config.get_scan_parameters()

print(string.format("nFRQ: %4d  F0: %.4f  F1: %.4f SRate: %.2f",
	nFRQ, F0, F1, SRate))

dF = DT.get_freq_step(tape)
-- Time per sweep (s)
dT = nFRQ / SRate
-- Distance traveled per sweep (m/sweep).
dD = dT * params.sen_vel

print(string.format("dF: %.4f vel: %.3f  dT: %.3f  dD: %.3f", dF, params.sen_vel, dT, dD))

------------------------------------------------------
function time2angle(t, dF)
	return t * 2 * math.pi * dF / 1000
end

function shift(cv, t, dF)
	return CV.rotate(cv, V(#cv, 0, 1) * time2angle(t, dF))
end

------------------------------------------------------
dt = DS.get_time_step(nFFT)
------------------------------------------------------
function plot_time(c)
	t = CV.fft(c, nFFT, F0, F1, true)
	P("P1", "P1", V(#t, 0, dt), CV.abs(t))
end

------------------------------------------------------
function plot_dist(c)
	t = CV.fft(c, nFFT, F0, F1, true)
	P("P2", "P2", V(#t, 0, 0.15 * dt), CV.abs(t))
end

-------------------------------------------------------
CL = config.get_combo_table() ; L.display(CL)
SL = config.get_sensor_table() ; L.display(SL)

function next_combo_header ()
	local i = 0 ; local fr = 0 ; local sw = 0
	return 
  		function ()
	 		i = i + 1 ; j = (i - 1) % #CL + 1
			if j == 1 then
				fr = fr + 1
				sw = sw + 1
			elseif CL[j].TX ~= CL[j-1].TX then
				sw = sw + 1
			end
			return CL[j], fr, sw
		end
end

next_combo_header = next_combo_header()

------------------------------------------------------
function bistatic_distance(combo, target, ts)

	if (params.sen_mov == false) then
		pos_tx = C(SL[combo.TX].X, SL[combo.TX].Y)
		pos_rx = C(SL[combo.RX].X, SL[combo.RX].Y)
	else
		pos_tx = GetCurrPos(SL[combo.TX].X, SL[combo.TX].Y, nil, params.sen_vel, params.sen_ang, ts)
		pos_rx = GetCurrPos(SL[combo.RX].X, SL[combo.RX].Y, nil, params.sen_vel, params.sen_ang, ts)
	end

	d_tx = C.abs(target - pos_tx) + (SL[combo.TX].TX_DELAY / cInNanoSecPerM)
	d_rx = C.abs(target - pos_rx) + (SL[combo.TX].RX_DELAY / cInNanoSecPerM)

	return d_tx + d_rx
end

------------------------------------------------------
function get_scan_data(combo, ts)

	local c = CV(nFRQ)
	for i = 1, #target do
		local d = 0
		if target[i].vel ~= nil then
			d = bistatic_distance(combo, GetCurrPos(target[i].x, target[i].y, nil, target[i].vel, target[i].ang, ts), ts)
		elseif target[i].rate ~= nil then
			d = bistatic_distance(combo, GetCurrPosBreath(target[i].x, target[i].y, nil, target[i].rate, target[i].throw, target[i].ang, ts), ts)
		end
		
		local A = CalcAmp (d, target[i].rcs, rcs_pow, F0, 10^(params.tx_gain/10), 10^(params.rx_gain/10), params.tx_pow, params.loss_factor, params.rx_fs_pow, params.pow_r)
		c = c + GetTargetResp (d, A, F0, dF , nFRQ)
	end

	return c
end

------------------------------------------------------
function next_timestamp(sw)
	return sw * dT
end

function set_obj_params(x_pos, y_pos, vel, rate, throw, ang, rcs)

	local obj = {}
	
	obj.x = x_pos
	obj.y = y_pos
	obj.vel = vel
	obj.rate = rate
	obj.throw = throw
	obj.ang = (2 * PI * ang) / 360
	obj.rcs = rcs

	return obj
end

function read_obj_params()

	local t = {}
	local n = 0
	if params.obj1 then
		n = n + 1
		t[n] = set_obj_params(params.obj1_x, params.obj1_y, params.obj1_vel, nil, nil, params.obj1_ang, params.obj1_rcs)
	end
	
	if params.obj2 then
		n = n + 1
		t[n] = set_obj_params(params.obj2_x, params.obj2_y, params.obj2_vel, nil, nil, params.obj2_ang, params.obj2_rcs)
	end
	
	if params.obj3 then
		n = n + 1
		t[n] = set_obj_params(params.obj3_x, params.obj3_y, params.obj3_vel, nil, nil, params.obj3_ang, params.obj3_rcs)
	end
	
	if params.obj_breath1 then
		n = n + 1
		t[n] = set_obj_params(params.obj_breath1_x, params.obj_breath1_y, nil, params.obj_breath1_rate, params.obj_breath1_throw, params.obj_breath1_ang, params.obj_breath1_rcs)
	end

	if params.obj_breath2 then
		n = n + 1
		t[n] = set_obj_params(params.obj_breath2_x, params.obj_breath2_y, nil, params.obj_breath2_rate, params.obj_breath2_throw, params.obj_breath2_ang, params.obj_breath2_rcs)
	end
	
	if params.obj_breath3 then
		n = n + 1
		t[n] = set_obj_params(params.obj_breath3_x, params.obj_breath3_y, nil, params.obj_breath3_rate, params.obj_breath3_throw, params.obj_breath3_ang, params.obj_breath3_rcs)
	end

	return t
end

target = read_obj_params()

total_time = 0; count = 1
------------------------------------------------------
while total_time < params.sim_time do

	local combo, fr, sw = next_combo_header()
	local tx, rx = combo.TX, combo.RX

	local ts = next_timestamp(sw)

	if ts < params.sim_time then
		local P = C(SL[rx].X, SL[rx].Y)
		
		-- Current location of the sensor
		if (params.sen_mov == true) then
			P = GetCurrPos(SL[rx].X, SL[rx].Y, nil, params.sen_vel, params.sen_ang, ts)
		end

		local S = SC()
		S.FRAME_NUMBER = fr
		S.SWEEP_NUMBER = sw
		S.TX = tx
		S.RX = rx
		S.TIMESTAMP = ts
		
		if params.noise == true then
			S.DATA = get_scan_data(combo, ts) + bg_noise_cv
		else
			S.DATA = get_scan_data(combo, ts)
		end
		S.ENCODER_X = P[1]
		S.ENCODER_Y = P[2]
		DT.append(tape, S)

		if (count % 50 == 0) then
			print(count, tx, rx, fr, sw,  
				string.format("%.3f %.2f %.2f", ts, P[1], P[2]))
		end
	end
	
	total_time = ts

	count = count + 1
end

if (params.out_file == true) then
	data_tape.write(tape, params.out_filename)
end

print("\n-------------------")
print("Simulation Complete")
print("-------------------\n")
forms.message("Simulated Data Generation Complete")
