-- Version 1.12, 01/24/2011
-- Author: Patton Gregg
-- Revision History:
--	1.12, 01/24/2011
--		Updated plotting function to plot results in log scale
--	1.11, 01/20/2011
--		Updated call to CalcGateDist for new param list
--	1.10, 12/08/2010
--		Deprecated CalcGateParams and separate harmonic testing with GetGateParams
--	1.00, 11/30/2010
--		Initial Release
-------------------------------------------------------------------------
-- Include Files
-------------------------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-Math.lua")
dofile("LuaProg/Lib-Radar.lua")
-------------------------------------------------------------------------
dofile("LuaProg/Tool-TDD-Calculator-Dialog.lua")
-------------------------------------------------------------------------

function get_new_parameters(params)

	local txcable_delay = params.txcable_delay
	local rxcable_delay = params.rxcable_delay
	local strt_dist = params.strt_dist
	local std_dist = params.std_dist
	local far_sig = params.far_sig
	
	local tx_width, tx_delay, rx_width, rx1_delay, rx2_width, rx_delay = GetGateParams(strt_dist, std_dist, far_sig, txcable_delay, rxcable_delay, params.max_duty)
	local startSigDist, startFullSigDist, endFullSigDist, endSigDist = CalcGateDist(tx_width, tx_delay, rx_width, rx_delay, txcable_delay, rxcable_delay)
	
	return
	{
		txcable_delay = txcable_delay,
		rxcable_delay = rxcable_delay,
		strt_dist = startSigDist,
		std_dist = startFullSigDist,
		far_sig = endFullSigDist,
		end_dist = endSigDist,
		tx_width = tx_width,
		tx_delay = tx_delay,
		rx_width = rx_width,
		rx_delay = rx_delay,
		program_TDD = params.program_TDD,
		duty_factor = 100 * (tx_width / (tx_width + rx_width + tx_delay + rx_delay)),
		gate_count = (tx_width + tx_delay + rx_width + rx_delay) / GateClock,
	}
end

-------------------------------------------------------------------------
function SetGateParams(params)
	gate = config.get_process_parameter_table()
	gate.ENABLE_GATE_VALUES = true
	gate.GATE_TX1 = params.tx_width
	gate.GATE_TX1_RX1 = params.tx_delay
	gate.GATE_RX1 = params.rx_width
	gate.GATE_RX1_RX2 = 0
	gate.GATE_RX2 = 0
	gate.GATE_RX2_TX1 = params.rx_delay
	config.set_process_parameter_table(gate)
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------

params = get_parameters()
params = get_new_parameters(params)
if (params.program_TDD) then
	SetGateParams(params)
end

w = window_manager.make(FL_TEXT_WINDOW, "CALCULATED GATING PARAMETERS")
t = {
		" - CALCULATED GATE VALUES - ",
		"*",
		string.format("Tx Width (ns):                            %.2f", params.tx_width),
		string.format("Tx-Rx Delay (ns):                         %.2f", params.tx_delay),
		string.format("Rx Width (ns):                            %.2f", params.rx_width),
		string.format("Rx1-Rx2 Delay (ns):                       %.0f", 0),
		string.format("Rx2 Width (ns):                           %.0f", 0),
		string.format("Rx-Tx Delay (ns):                         %.2f", params.rx_delay),
		"*",
		string.format("Duty Factor:                              %.2f", params.duty_factor),	
		string.format("Total Gate Counts:                        %.0f", params.gate_count),
		"*",
		"*",
		" - EFFECTIVE SIGNAL DISTANCES - ",
		"*",
		string.format("Signal Start Distance:                    %.1f m", params.strt_dist),
		string.format("Full Signal Start Distance:               %.1f m", params.std_dist),
		string.format("Full Signal End Distance:                 %.1f m", params.far_sig),
		string.format("Signal End Distance:                      %.1f m", params.end_dist),	
		"*",
	}

window_manager.update(w, t)

----------------------------------------------------------

function getVUp(start, finish, maxv)
	-- return V((finish-start)*10, 0, maxv/((finish-start)*10))
	return V((finish-start)*10, 0, maxv/((finish-start)*10))
end

function getVFlat(start, finish, value)
	return V((finish-start)*10,value)
end

function getVDown(start, finish, maxv)
	return V((finish-start)*10,maxv-maxv/((finish-start)*10),-maxv/((finish-start)*10))
end


signal_level = V(params.strt_dist*10, 0)
V.append(signal_level, getVUp(params.strt_dist, params.std_dist, params.duty_factor))
V.append(signal_level, getVFlat(params.std_dist, params.far_sig, params.duty_factor))
V.append(signal_level, getVDown(params.far_sig, params.end_dist, params.duty_factor))
-- V.append(signal_level, getVFlat(params.end_dist, params.end_dist + 10, 0))

minPlotSigLev = 0.01
I = V.find(signal_level, function (x) return x < minPlotSigLev end)
signal_level[I] = minPlotSigLev

signal_level_db = 20 * V.log10(signal_level / 100)

signal_chart = chart("GATE PARAMETER SIGNAL LEVELS", FL_CHART_WINDOW)
x_values = V(#signal_level, params.end_dist/#signal_level, params.end_dist/#signal_level)

chart.add(signal_chart, x_values, signal_level_db, "Signal Level vs Distance", string.format("Signal Start Dist - %.1f m, Full Signal Start Dist - %.1f m, Full Signal End Dist - %.1f m", params.strt_dist, params.std_dist, params.far_sig))  
-- chart.add(signal_chart, x_values, signal_level, "Signal Level vs Distance", string.format("Signal Start Dist - %.1f m, Full Signal Start Dist - %.1f m, Full Signal End Dist - %.1f m", params.strt_dist, params.std_dist, params.far_sig))  
chart.set_xlabel(signal_chart, "Distance (m)")
chart.set_ylabel(signal_chart, "Relative to CW (dB)")
chart.set_scale(signal_chart, 0, params.end_dist, 0, -40)
-- chart.set_scale(signal_chart, 0, params.end_dist, 0, 100)
chart.update(signal_chart)