--
-- Tool-K-THETA-Calibration
--

Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

dofile("LuaProg/UTIL-Header.lua")

function interpolate(v, w)
	local u = CV(#v)
	local j = 2
	for i = 1, #v do
		while j < #w and v[i] > w[j][1] do
			j = j + 1
		end
		local slope = (w[j][2] - w[j-1][2]) / (w[j][1] - w[j-1][1])
		u[i] = complex(v[i], slope * (v[i] - w[j-1][1]) + w[j-1][2] )
	end
	return u	
end

function find_filename(IP, PORT)
	local CT  = {
		{IP = "*", "Quadridge Horn.txt", "Quadridge Horn.txt"}
	}

	for i = 1, #CT do
		if CT[i].IP == "*" or CT[i].IP == IP then
			return CT[i][math.max(PORT, 1)]
		end
	end
	return nil
end

SL = config.get_sensor_table()
--for k,v in pairs(SL) do
--	print(k, v)
--end


function get_calibration_list()

	local calibration_list = {}

	for i = 1, #SL do
		IP = SL[i].IP
		if SL.ANTENNA_SWITCH then
			local fn = find_filename(SL[i].IP, SL[i].PORT)
			calibration_list[fn] = 0
		else
			local fn1 = find_filename(SL[i].IP, SL[i].TX_PORT)
			local fn2 = find_filename(SL[i].IP, SL[i].RX_PORT)
			calibration_list[fn1] = 0
			calibration_list[fn2] = 0
		end
	end
	local NP, F0, F1 = DS.get_scan_parameters()
	local dF = data_source.get_freq_step(NP, F0, F1)

	local f = V(NP, F0, dF)

	local dir = "C:/AKELA-TEST-ANALYSIS/Group Delay Calibration/"

	for k,v in pairs(calibration_list) do
		m = file.read_marker_vector(dir .. k)
		calibration_list[k] = interpolate(f, m)
	end

	return calibration_list
end

calibration_list = {}

function Initialize()
	calibration_list = get_calibration_list()
	Lua.display("calibration_list", calibration_list)
end

function apply_group_delay(data)
	x = CV.rotate(data, CV.imag(GROUP_CALIBRATION))
	return x
end

function find_phase_correction(scan)

	local TX = SL[scan.TX]
	local RX = SL[scan.RX]

	local TP = SL.ANTENNA_SWITCH and TX.PORT or scan.TX_PORT
	local RP = SL.ANTENNA_SWITCH and RX.PORT or scan.RX_PORT

	local TN = find_filename(TX.IP, TP)
	local RN = find_filename(RX.IP, RP)

	local TV = calibration_list[TN]
	local RV = calibration_list[RN]

	return TV, RV
end

function Process(scan)

	local tx_corr, rx_corr = find_phase_correction(scan)

	local data = scan.DATA
	data = CV.rotate(data, CV.imag(tx_corr))
--	data = CV.rotate(data, CV.imag(rx_corr))
	scan.DATA = data

	return scan
end
