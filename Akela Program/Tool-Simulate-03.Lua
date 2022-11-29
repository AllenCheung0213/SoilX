L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 C = complex
 V = vector
CM = complex_matrix
 M = matrix
DS = data_source
DT = data_tape
SC = data_scan

-------------------------------------------------------
tape = DS.get_tape() ; DT.clear(tape)

nFFT = 8192		-- debug only
VEL = 30.0		--s mph
DIST = 30		-- meters 

------------------------------------------------------
target = CV { 
	C(-10, 1000),
	C( 10, 1000),
	C(  0, 1005),
	C(-10, 1010),
	C( 10, 1010)
}

orig_target = CV(target)

-------------------------------------------------------
nFRQ, F0, F1, SRate = DT.get_scan_parameters(tape)

print(string.format("nFRQ: %4d  F0: %.4f  F1: %.4f SRate: %.2f",
	nFRQ, F0, F1, SRate))

dF = DT.get_freq_step(tape)
dT = DT.get_time_step(tape, nFFT)

print(string.format("dF: %.4f  dT: %.4f", dF, dT))

-- Velocity (meter/s)
vel = VEL * 0.44705

-- Time per sweep (s)
dT = nFRQ / SRate

-- Distance traveled per sweep (m/sweep).
dD = dT * vel

EP = config.get_encoder_parameter_table()

-- Encoder counts per meter (c/m)
dC = EP[1].COUNTS_PER_REVOLUTION / EP[1].WHEEL_CIRCUMFERENCE

-- Counts per sweep
dE = dD * dC


print(string.format("vel: %.3f  dT: %.4f  dD: %.4f  dE: %.4f", vel, dT, dD, dE))

------------------------------------------------------
------------------------------------------------------
function time2angle(t)
	return t * 2 * PI * dF / 1000
end

function shift(cv, t)
	return CV.rotate(cv, V(#cv, 0, 1) * time2angle(t))
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
function make_scan()

	--Speed of light: m/s
	local c = 0.30e9
	--Frequency: Hz
	local FRQ = V(nFRQ, F0, dF) * 1.e6
	local LAM = c / FRQ

	local MOD = V(nFRQ, 1, 0)

	return 
		function (r)
	
			local V1 = 1 / CV( V(nFRQ), r * LAM )
	
			local ARG = (2 * PI * r) / LAM
	
			local V2 = CV.polar( MOD, ARG )
	
			return 1000 * V1 * V2
		end
end

make_scan = make_scan()

------------------------------------------------------
function bistatic_distance(combo, target, currP, currT)

	p1 = C(SL[combo.TX].X, SL[combo.TX].Y)
	p2 = C(SL[combo.RX].X, SL[combo.RX].Y)

	p1 = C.rotate(p1, -currT)
	p2 = C.rotate(p2, -currT)

	d1 = C.abs(p1 + currP - target)
	d2 = C.abs(p2 + currP - target)

	return d1 + d2

end

------------------------------------------------------
function get_scan_data(combo, currP, currT)

	local c = CV(nFFT)

	for i = 1, #target do
		local d = bistatic_distance(combo, target[i], currP, currT)
		c = c + make_scan(d)
	end

	--plot_time(c)
	--plot_dist(c)

	return CV( CV.imag(c), CV.real(c) )
end

------------------------------------------------------
function next_encoder_count(sw)
	return 0
end
	
------------------------------------------------------
function next_timestamp(sw)
	return sw * dT
end

delta_y = 0.1
------------------------------------------------------
function next_position(sw)
	local dT = 0
	local x = 0
	local y = 0
	return C(x, y), 0
end

total_motion = 0; count = 1
------------------------------------------------------
while true do

	local combo, fr, sw = next_combo_header()
	local tx, rx = combo.TX, combo.RX

	local ec = next_encoder_count(sw)
	local ts = next_timestamp(sw)

	-- Current location of the sensor
	local P, THETA = next_position(sw)

	local S = SC()

	if (sw - 1) * delta_y > 2.0 then break end

	target[3] = orig_target[3] + C(0, (sw - 1) * delta_y)

	S.FRAME_NUMBER = fr
	S.SWEEP_NUMBER = sw
	S.TX = tx
	S.RX = rx
	S.TX_PORT = 0
	S.RX_PORT = 0
	S.TIMESTAMP = ts
	S.DATA = get_scan_data(combo, P, THETA)
	S.ENCODER_X = P[1]
	S.ENCODER_Y = P[2]
	S.ENCODER_THETA = THETA
	S.ENCODER_LSE = ec
	S.ENCODER_RSE = ec

	DT.append(tape, S)

--[[
	print(
		string.format("%4d %3d %3d %3d %3d", count, tx, rx, fr, sw), P, THETA,
		string.format("%.3f %.2f", ts, total_motion) )
--]]
	total_motion = sw * delta_y

	count = count + 1
end
