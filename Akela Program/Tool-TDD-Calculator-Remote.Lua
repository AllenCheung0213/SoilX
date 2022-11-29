-- Title: TDD Calculator Remote
-- Filename: Tool-TDD-Calculator-Remote.lua
-- Description: Calculates the gate parameters from a remote command
-- Version 1.0.0, 02/24/2011
-- Author: Patton Gregg
-- Revision History:
--	1.0.0, 02/24/2011
--		Updated GATE_REPORT to add gate values, and released for general use
--	0.9.2 Beta, 01/13/2011
--		Update get_gate_parameters function with new return values for GetTDDGateParams function
--	0.9.1 Beta, 12/08/2010
--		Added error checking
--	0.9.0 Beta, 12/08/2010
--		Functional calculator with on error correction
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-Radar.lua")
--------------------------------------------------------
-- Global Variables
--------------------------------------------------------
GATE_REPORT = ""

function set_gate_report(txGate, txGateDelay, rxGate, rxGateDelay, errMsg)
	
	local SL = config.get_sensor_table()
	local txCableDelay = GetMaxTXDelay(SL)	
	local rxCableDelay = GetMaxRXDelay(SL)
	local maxAntDist = GetMaxAntDist(SL)
	
	local startSigDist, startFullSigDist, endFullSigDist, endSigDist = CalcGateDist(txGate, txGateDelay, rxGate, rxGateDelay, txCableDelay, rxCableDelay, false)

	GATE_REPORT = GATE_REPORT .. "\n" .. " - CALCULATED GATE VALUES - "
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Tx Width (ns): %.2f", txGate)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Tx-Rx Delay (ns): %.2f", txGateDelay)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Rx Width (ns): %.2f", rxGate)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Rx1-Rx2 Delay (ns): %.0f", 0)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Rx2 Width (ns): %.0f", 0)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Rx-Tx Delay (ns): %.2f", rxGateDelay)
	GATE_REPORT = GATE_REPORT .. "\n" .. " - EFFECTIVE SIGNAL DISTANCES - "
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Signal Start Distance (m): %.1f", startSigDist)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Full Signal Start Distance (m): %.1f", startFullSigDist)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Full Signal End Distance (m): %.1f", endFullSigDist)
	GATE_REPORT = GATE_REPORT .. "\n" .. string.format("Signal End Distance (m): %.1f", endSigDist)
	
	if errMsg ~= "" then
		GATE_REPORT = GATE_REPORT .. "\n" .. " - ERRORS(S) IN GATE PARAMETERS INPUT - "
		GATE_REPORT = GATE_REPORT .. errMsg
	end
end

function get_gate_report()
	return GATE_REPORT
end

function get_gate_parameters (startSigDist, startFullSigDist, endFullSigDist)
	
	local SL = config.get_sensor_table()
	local txCableDelay = GetMaxTXDelay(SL)	
	local rxCableDelay = GetMaxRXDelay(SL)
	local maxAntDist = GetMaxAntDist(SL)

	startSigDist, startFullSigDist, endFullSigDist, errMsg = CheckGateDistParams(startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxAntDist)

	local txGate, txGateDelay, rxGate, rx2GateDelay, rx2Gate, rxGateDelay = GetGateParams(startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, false)

	set_gate_report(txGate, txGateDelay, rxGate, rxGateDelay, errMsg)
	
	return true, txGate, txGateDelay, rxGate, rx2GateDelay, rx2Gate, rxGateDelay
end

