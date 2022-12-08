VERSION = "2.54, 02/24/2011"
-- Author: Patton Gregg
------
-- Revision History
-- 2.54, 02/24/2011:
--		Moved GetCSVNum into the Lib-String library file and changed name to GetCommaSepNums
-- 2.53, 02/02/2011:
--		Fixed bug in GetCSVNum that caused function to not read decimals
-- 2.52, 02/02/2011:
--		Fixed bug in reading GATE_VALUES field
-- 2.51, 01/19/2011:
--		Optimized and fixed error reporting bugs in GetCSV function 
-- 2.50, 01/12/2011:
--		Deprecated GATE_MIN_RANGE and GATE_MAX_RANGE
--		Added GATE_RANGES parameter for specifying TDD gate parameters as a function of desired
--			gate ranges
-- 2.41, 11/17/2010:
--		Consolidated many functions defined in this script and placed into libraries
--		Set up system for handling errors
-- 2.40, 10/18/2010:
--		Added parameter GATE_VALUES for specifying all gate values in a single field
-- 2.30, 09/09/2010:
--		Fixed bug in interpretation routine for TX, RX, and MONO field values
--		Changed dialog to provide control of port mapping for polarization
--		Changed dialog to provide control of force of auto save and increment
--		Changed string operators to allow spaces in field names
--		Updated interpretation function to strip leading and trailing quotation marks from strings
--		Updated error report when there is an empty field in the parameters file
-- 2.20, 09/03/2010:
--		Removed port specifications for specifying Polarization as "Both" and "All"
-- 2.10, 09/02/2010:		
--		Fixed bug that caused transmitters to be disabled if TX, RX or MONO fields == None
-- 2.00:		
--		Added special fields to define sets of parameters
-- 1.00:		
--		Initial release

--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-File.lua")
dofile("LuaProg/Lib-Table.lua")
dofile("LuaProg/Lib-Type.lua")
dofile("LuaProg/Lib-Radar.lua")
dofile("LuaProg/Lib-String.lua")
--------------------------------------------------------

DEBUG = false

function verify(params)
	
	local no_errors = true
	
	-- Check files
	if (FileExists(params.config_base) == false) then
		forms.message("Invalid Baseline Configuration File!")
		no_errors = false
	end

	if (FileExists(params.config_params) == false) then
		forms.message("Invalid Configuration Parameters File!")
		no_errors = false
	end
	
	return no_errors
end

function ErrorCheck(err)

	if err ~= nil then
		RestoreConfig()
		forms.error(err)
	end
end

function ChangeParameters(baseTable, paramTable, paramType)

	local newTable = baseTable

	for k,v in pairs(paramTable) do
		if (baseTable[k] ~= nil) then
			if (IsBool(paramTable[k])) then
				newTable[k] = StringToBool(paramTable[k])
			else
				newTable[k] = paramTable[k]
			end
		elseif (paramType ~= nil) then
			if (string.find(k, paramType) ~= nil) then 
				_, _, num, field = string.find(k, "%p(%d+)%p%p([%w%p%s]+)")
				if (newTable[num+1][field] ~= nil) then
					if (IsBool(v)) then
						newTable[num+1][field] = StringToBool(v)
					else
						newTable[num+1][field] = v
					end
				else
					return newTable, string.format("Invalid parameter field: %s", k)
				end
			end
		end
	end

	return newTable, nil
end

--------------------------------------------------------
-- System Parameters
--------------------------------------------------------
function SetSystemParameters(paramTable)

	local SP = config.get_system_parameter_table()

	SP, err = ChangeParameters(SP, paramTable, nil)
	
	ErrorCheck(err)

	config.set_system_parameter_table(SP)
end

--------------------------------------------------------
-- Analysis Parameters
--------------------------------------------------------
function SetAnalysisParameters(paramTable)

	local AP = config.get_analysis_parameter_table()

	AP, err = ChangeParameters(AP, paramTable, nil)
	
	ErrorCheck(err)
	
	config.set_analysis_parameter_table(AP)
end

--------------------------------------------------------
-- Hardware Parameters
--------------------------------------------------------
function SetHardwareParameters(paramTable)

	local HP = config.get_hardware_parameter_table()
	
	HP, err = ChangeParameters(HP, paramTable, nil)
	
	ErrorCheck(err)
	
	config.set_hardware_parameter_table(HP)
end

--------------------------------------------------------
-- Process Parameters
--------------------------------------------------------
function SetProcessParameters(paramTable)

	local PP = config.get_process_parameter_table()

	PP, err = ChangeParameters(PP, paramTable, nil)
	
	ErrorCheck(err)
	
	config.set_process_parameter_table(PP)
end

--------------------------------------------------------
-- Scan Parameters
--------------------------------------------------------
function SetScanParameters(paramTable)

	local SP = config.get_scan_parameter_table()

	SP, err = ChangeParameters(SP, paramTable, nil)
	
	ErrorCheck(err)
	
	config.set_scan_parameter_table(SP)
end

--------------------------------------------------------
-- Encoder Parameters
--------------------------------------------------------
function SetEncoderParameters(paramTable)

	local EP = config.get_encoder_parameter_table()

	EP, err = ChangeParameters(EP, paramTable, "ENCODER")

	ErrorCheck(err)
	
	config.set_encoder_parameter_table(EP)
end

-------------------------------------------------------
-- Sensor Parameters
--------------------------------------------------------
function SetSensorParameters(paramTable)

	local SP = config.get_sensor_table()

	SP, err = ChangeParameters(SP, paramTable, "SENSOR")
	
	ErrorCheck(err)
	
	config.set_sensor_table(SP)
end

-- Read the parameter file and propogate the parameter table
function GetParamTable (paramFile)

	local numConfigs = 0
	local numFields = 0

	local paramTable = {}
	local paramTableFields = {}

	io.input(paramFile)

	-- Read first line of the file and set the keys for the change table
	line = io.read()

	if line == nil then
		local err = "Empty file header!"
		return nil, nil, err
	else
		local i = 0
		
		while true do
			_, i, fieldName = string.find(line, "([%w%p ]+)", i+1)
			if (fieldName == nil) then
				break
			else
				numFields = numFields + 1
				paramTableFields[numFields] = string.upper(fieldName)
			end
		end
	end

	if (DEBUG) then
		DisplayTable(paramTableFields, "Parameter Fields")
	end
	
	-- Read the rest of the lines and set the tables
	while true do

		local line = io.read()
		local fieldValues = {}
		
		if line == nil then
			break
		elseif string.find(line, "([%w%p ]+)") ~= nil then
			
			local i = 0
			for j = 1, numFields do
				_, i, fieldValue = string.find(line, "([%w%p ]+)", i+1)
				if (fieldValue == nil) then
					err = "There is an empty field in config #" .. numConfigs + 1 .. "!"
					return nil, nil, "There is an empty field in config #" .. numConfigs + 1 .. "!"
				else
					fieldValues[paramTableFields[j]] = fieldValue
				end
			end
			
			-- Set change table parameter values
			table.insert(paramTable, fieldValues)
			numConfigs = numConfigs + 1
			if (DEBUG) then
				DisplayTable(fieldValues, "Parameter Table " .. numConfigs .. " Field Values")
			end
		end
	end

	if (paramTable[1].CFG_FILENAME == nil) then
		local err = "No configuration filename field has been defined!"
		return nil, nil, err
	end
	
	return numConfigs, paramTable, nil
end

function SetSensSeries(v, n1, n2) 

	for n = n1, n2 do
		v[n+1] = 1
	end	
	
	return v
end

function InterpParams (numConfigs, paramTable)

	local sensorsP = config.get_sensor_table()

	local nSensors = 0
	for k2,v2 in pairs(sensorsP) do
		if L.is_table(v2) then
			nSensors = nSensors + 1
		end
	end

	for i = 1, numConfigs do
		tempTable = {}
		for k,v in pairs(paramTable[i]) do
			-- print("k, v", k, v)
			if (k == "TX" or k == "RX" or k == "MONO") then
				local sensorsEn = V(nSensors, 0)
				if (string.upper(v) == "ALL") then
					sensorsEn = V(nSensors, 1)
				elseif (string.upper(v) == "NONE") then
					sensorsEn = V(nSensors, 0)
				else
					local j = 0
					local buff1
					local buff2
					local state = 1
					while true do
						_, j, char = string.find(v, "([\-,%d ])", j+1)
						
						if (char == " ") then
							if (state == 2 or state == 3) then
								state = 3
							elseif (state == 5) then
								SetSensSeries(sensorsEn, buff1, buff2)
								state = 6
							end
						elseif (IsNum(char)) then
							if (state == 1) then
								buff1 = char
								state = 2
							elseif (state == 2) then
								buff1 = buff1 .. char
							elseif (state == 3) then
								sensorsEn[buff1+1] = 1
								buff1 = char
								state = 2
							elseif (state == 4) then
								buff2 = char
								state = 5
							elseif (state == 5) then
								buff2 = buff2 .. char
							elseif (state == 6) then
								buff1 = char
								state = 2
							end
						elseif (char == "-") then
							if (state == 1 or state == 4 or state == 5) then
								forms.error("Syntax error in field: " .. k .. " for config #" .. i .. "!")
							elseif (state == 2 or state == 3) then
								state = 4
							end
						elseif (char == ",") then
							if (state == 1 or state == 4) then
								forms.error("Syntax error in field: " .. k .. " for config #" .. i .. "!")
							elseif (state == 2) then
								sensorsEn[buff1+1] = 1
								buff1 = nil
								state = 6
							elseif (state == 3) then
								sensorsEn[buff1+1] = 1
								buff1 = nil
								state = 2
							elseif (state == 5) then
								SetSensSeries(sensorsEn, buff1, buff2)
								state = 6
							end
						elseif (char == nil) then
							if (state == 1 or state == 4) then
								forms.error("Syntax error in field: " .. k .. " for config #" .. i .. "!")
							elseif (state == 2 or state == 3) then
								sensorsEn[buff1+1] = 1
							elseif (state == 5) then
								SetSensSeries(sensorsEn, buff1, buff2)
							end
							break
						end
					end
				end

				if (k == "TX" and string.upper(v) == "NONE") then
					paramTable[i].STATUS_TX = "FALSE"
				end
				
				for n = 1, nSensors do
					local field = "SENSOR[" .. n-1 .. "]." .. k
					if (sensorsEn[n] == 1 and sensorsP[n].TYPE ~= "ARRAY_MASTER" and sensorsP[n].TYPE ~= "PSEUDO_MASTER") then
						tempTable[field] = "TRUE"
					else
						tempTable[field] = "FALSE"
					end
				end

				paramTable[i][k] = nil
			elseif (k == "POL" or k == "POLARIZATION") then
				v = string.upper(v)
				for n = 1, nSensors do
					local fieldTXPort = "SENSOR[" .. n-1 .. "].TX_PORT" 
					local fieldRXPort = "SENSOR[" .. n-1 .. "].RX_PORT"
					
					if (v == "HH" or v == "H") then
						tempTable[fieldTXPort] = params.hPortNum
						tempTable[fieldRXPort] = params.hPortNum
					elseif (v == "VV" or v == "V") then
						tempTable[fieldTXPort] = params.vPortNum
						tempTable[fieldRXPort] = params.vPortNum
					elseif (v == "HV") then
						tempTable[fieldTXPort] = params.hPortNum
						tempTable[fieldRXPort] = params.vPortNum
					elseif (v == "VH") then
						tempTable[fieldTXPort] = params.vPortNum
						tempTable[fieldRXPort] = params.hPortNum
					elseif (v == "BOTH") then
						tempTable.ALTERNATE_TX = "FALSE"
						tempTable.ALTERNATE_RX = "FALSE"
						tempTable.ALTERNATE_TXRX = "TRUE"
					elseif (v == "ALL") then
						tempTable.ALTERNATE_TX = "TRUE"
						tempTable.ALTERNATE_RX = "TRUE"
						tempTable.ALTERNATE_TXRX = "FALSE"
					else
						forms.error("Invalid polarization: " .. k .. " for config #" .. i .. "!")
					end
				end
				
				paramTable[i][k] = nil
			end

			-- Strips leading and trailing quotation marks from all strings
			if (type(v) == "string") then
				paramTable[i][k] = string.gsub(v, "^\"", "")
				paramTable[i][k] = string.gsub(paramTable[i][k], "\"$", "")
			end
		end	

		if paramTable[i].GATE_RANGES ~= nil then
			local gateRangeVal, err = GetCommaSepNums(paramTable[i].GATE_RANGES)

			if err then
				forms.error("Syntax error in field: GATE_RANGES for config #" .. i .. "!")
			elseif #gateRangeVal ~= 3 then
				forms.error("Syntax error in field: GATE_RANGES for config #" .. i .. "! Only 3 values expected!")
			end
			
			SetSensorParameters(paramTable[i])
			local SL = config.get_sensor_table()
			local txCableDelay = GetMaxTXDelay(SL)	
			local rxCableDelay = GetMaxRXDelay(SL)
			local maxAntDist = GetMaxAntDist(SL)
				
			local startSigDist, startFullSigDist, endFullSigDist, errMsg = CheckGateDistParams(gateRangeVal[1], gateRangeVal[2], gateRangeVal[3], txCableDelay, rxCableDelay, maxAntDist)
			local txGate, txGateDelay, rxGate, rx2GateDelay, rx2Gate, rxGateDelay = GetGateParams(startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, false)
			paramTable[i].GATE_TX1 = txGate
			paramTable[i].GATE_TX1_RX1  = txGateDelay
			paramTable[i].GATE_RX1 = rxGate
			paramTable[i].GATE_RX1_RX2 = rx2GateDelay
			paramTable[i].GATE_RX2 = rx2Gate
			paramTable[i].GATE_RX2_TX1 = rxGateDelay

			paramTable[i].GATE_RANGES = nil
		elseif paramTable[i].GATE_VALUES ~= nil then
			local gateValue = GetCommaSepNums(paramTable[i].GATE_VALUES)
			
			if err then
				forms.error("Syntax error in field: GATE_VALUES for config #" .. i .. "!")
			elseif #gateValue ~= 6 then
				forms.error("Syntax error in field: GATE_VALUES for config #" .. i .. "! Only 6 values expected!")
			end

			paramTable[i].GATE_TX1 = gateValue[1]
			paramTable[i].GATE_TX1_RX1  = gateValue[2]
			paramTable[i].GATE_RX1 = gateValue[3]
			paramTable[i].GATE_RX1_RX2 = gateValue[4]
			paramTable[i].GATE_RX2 = gateValue[5]
			paramTable[i].GATE_RX2_TX1 = gateValue[6]

			paramTable[i].GATE_VALUES = nil
		end
		
		if (paramTable[i].DATA_FILENAME == nil) then
			paramTable[i].DATA_FILENAME = string.gsub(paramTable[i].CFG_FILENAME, "\.cfg", "")
		end

		-- Force the LNA and POWER_AMP to be disabled if the TDD gating is disabled
		if paramTable[i].ENABLE_GATE_VALUES ~= nil then
			if paramTable[i].ENABLE_GATE_VALUES == "FALSE" then
				paramTable[i].LNA = "FALSE"
				paramTable[i].POWER_AMP = "FALSE"
			elseif (paramTable[i].ENABLE_GATE_VALUES ~= "TRUE") then
				forms.error("Invalid ENABLE_GATE_VALUES field value: " .. paramTable[i].ENABLE_GATE_VALUES .. " for config #" .. i .. "!")
			end
		end
		
		-- Force data to be saved and the file name auto incremented
		if (params.saveData == true) then
			paramTable[i].SAVE_DATA = "TRUE"
		end
		
		if (params.autoIncFile == true) then
			paramTable[i].AUTO_INCREMENT_FILENAME = "TRUE"
		end
		
		AppendTable(paramTable[i], tempTable)
	
		if (DEBUG) then
			DisplayTable(paramTable[i], "Parameter Table " .. i .. " Field Values")
		end
	end

	return paramTable
end

-- Write out the config files from the parameter table
function WriteConfigFiles (numConfigs, paramTable, baseConfigFile)

	if (DEBUG) then
		DisplayTable(paramTable, "Parameter Table")
	end
	
	-- Set Config Parameters and Write File(s)
	for i = 1, numConfigs do
	
		config.read(baseConfigFile)
		
		SetSystemParameters(paramTable[i])
		SetAnalysisParameters(paramTable[i])
		SetHardwareParameters(paramTable[i])
		SetProcessParameters(paramTable[i])
		SetScanParameters(paramTable[i])
		SetEncoderParameters(paramTable[i])
		SetSensorParameters(paramTable[i])
		
		local outputString = ""
		if (params.out_dir ~= "") then
			outputString = params.out_dir .. "/" .. paramTable[i].CFG_FILENAME
		else
			outputString = paramTable[i].CFG_FILENAME
			if (i == 1) then
				forms.message("No output directory specified. Files will be output to the root APRD directory.")
			end
		end
		
		config.write(outputString)
	end
end

function RestoreConfig()

	config.set_system_parameter_table(origSysP)
	config.set_analysis_parameter_table(origAP)
	config.set_hardware_parameter_table(origHP)
	config.set_process_parameter_table(origPP)
	config.set_scan_parameter_table(origScanP)
	config.set_encoder_parameter_table(origEP)
	config.set_sensor_table(origSensP)
end

dofile("LuaProg/Tool-Batch-Config-Dialog.lua")

params = get_parameters()
if params == nil then error() end

-- Store Current APRD Config to Restore Later
origSysP = config.get_system_parameter_table()
origAP = config.get_analysis_parameter_table()
origHP = config.get_hardware_parameter_table()
origPP = config.get_process_parameter_table()
origScanP = config.get_scan_parameter_table()
origEP = config.get_encoder_parameter_table()
origSensP = config.get_sensor_table()

-- Load Baseline Config
config.read(params.config_base)

numConfigs, paramTable, err = GetParamTable(params.config_params)
ErrorCheck(err)

paramTable = InterpParams(numConfigs, paramTable)

WriteConfigFiles(numConfigs, paramTable, params.config_base)

if (numConfigs < 500) then
	forms.message("Configuration generation is complete! Good luck on your testing!")
else
	forms.message("Configuration generation is complete!\n(Holy *#$%! That was a lot of configurations!)")
end

-- Restore Original APRD Config
RestoreConfig()