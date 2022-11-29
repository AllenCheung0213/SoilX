-- Version 1.12, 01/24/2011
-------------------------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-Math.lua")
dofile("LuaProg/Lib-Radar.lua")
-------------------------------------------------------------------------

SL = config.get_sensor_table()
txdelay = GetMaxTXDelay(SL)	
rxdelay = GetMaxRXDelay(SL)
maxAntDist = GetMaxAntDist(SL)

local PARAMS_FILE = "LuaProg/Tool-TDD-Calculator-Parameters.lua"

----------------------------------------------------------
function edit_parameters(params)

	function verify(params)
		
		txcable_delay_dist = params.txcable_delay / cInNanoSecPerM
		rxcable_delay_dist = params.rxcable_delay / cInNanoSecPerM
		cable_delay_dist = txcable_delay_dist + rxcable_delay_dist
		min_TDD_delay = (3 * GateClock) / cInNanoSecPerM -- meters; equiv. to 3 TDD clock cycles
		
		startSigDist, startFullSigDist, endFullSigDist, errMsg = CheckGateDistParams(params.strt_dist, params.std_dist, params.far_sig, params.txcable_delay, params.rxcable_delay, maxAntDist)
		
		if errMsg ~= "" then
			forms.warning(errMsg)
			return false
		end
		
		return true
	end

	d = dialog("Pulse Modulator Calculator - v1.12, 01/24/2011", 470, 420, 220, 35)
	
	dialog.begin_tab(d, "Inputs")
	
	dialog.control(d, "System Parameters", BOX, FL_ENGRAVED_BOX)

	dialog.control(d, "Tx Cable Delay (ns)", NUMBER, "txcable_delay", params.txcable_delay)
	dialog.control(d, "Rx Cable Delay (ns)", NUMBER, "rxcable_delay", params.rxcable_delay)
	dialog.control(d, "Max Antenna Distance (m)", NUMBER, "max_ant_dist", params.max_ant_dist)

	dialog.control(d, "Gate Parameters", BOX, FL_ENGRAVED_BOX)

	dialog.control(d, "Signal Start Distance (m)", NUMBER, "strt_dist", params.strt_dist)
	dialog.control(d, "Full Signal Start Distance (m)", NUMBER, "std_dist", params.std_dist)
 	dialog.control(d, "Full Signal End Distance (m)", NUMBER, "far_sig", params.far_sig)
	dialog.control(d, "Auto. Set Values to HW Params.", CHECKBOX, "program_TDD", params.program_TDD)
	dialog.control(d, "Maximize Duty Cycle", CHECKBOX, "max_duty", params.max_duty)
	
	dialog.end_tab(d)
	
	return dialog.show(d)
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

local default_params = 
{
	txcable_delay = txdelay,
	rxcable_delay = rxdelay,
	strt_dist = 3,
	std_dist = 7,
	far_sig = 20,
	tx_delay = 0,
	rx_delay = 0,
	tx_width = 0,
	rx_width = 0,
	program_TDD = false,
	max_duty = false,
	max_ant_dist = maxAntDist
}

-------------------------------------------------------------------------


function get_parameters()

	local filename = "LuaProg/Tool-TDD-Calculator-Parameters.lua"
	
	local params

	params_file, err = io.open(filename, "r")
	if err then
		params = default_params
	else
		params = L.read_table(filename)
		params.txcable_delay = txdelay
		params.rxcable_delay = rxdelay
		params.max_ant_dist = maxAntDist		
	end

	params = edit_parameters(params)
	if params == nil then
		error("User canceled operation")
	else
		L.write_table(filename, params)
	end

	return params
end