VERSION = "v1.6.8, 03/30/2011"
-- Title: Data Processing Tools
-- Filename: Tool-Data-Proc.lua
-- Description: A set of tools for processing data files.
-- Author: Patton Gregg
-- Revision History:
--	1.6.8, 03/30/2011
-- 		Added functionality to edit a data file based on timestamps
--	1.6.7, 03/11/2011
--		General clean up of the code
--	1.6.6, 02/24/2011
--		Added functionality to specify an alternative directory to output files to
--	1.6.5, 02/23/2011
--		Changed output settings for position data tool
--	1.6.4, 02/21/2011
--		Fixed bug in saving the MinMax time charts
--	1.6.3, 01/27/2011
--		Added functionality to subtract a running average
--	1.6.2, 01/18/2011
--		Fixed bug in plotting the MinMax distance and time charts
--	1.6.1, 01/11/2011
--		Added functionality to exclude points in specified band for frequency band output
--		Updated MinMax processes to output a description of the chart in the filename
--	1.6.0, 12/17/2010
--		Added additional functionality to MinMax... tools
--		Reorganized MinMax functions and created new Lib-Plot for plotting functions
--	1.5.2, 12/16/2010
--		Moved min_max_freq function to Lib-Tape and renamed MinMaxTapeFreq
--		Moved min_max_dist function to Lib-Tape and renamed MinMaxTapeDist
--		Moved min_max_time function to Lib-Tape and renamed MinMaxTapeTime 
--		Moved bg_sub function to Lib-Tape and renamed SubtractTape 
--		Moved output_header function to Lib-File and renamed OutputHeader 
--	1.5.1, 11/24/2010
--		Reorganized the dialog tabs
--		Added Min/Max envelope charting in frequency and time domain
--	1.5.0, 11/23/2010
--		Extracted functions and organized as function libraries
--	1.4.7, 10/25/2010
--		Changed a few of the dialog box labels
--	1.4.6, 07/19/2010
-- 		Added a message to notify the user when the processing is complete
--		Updated the TimeWindowScan function to work with the corrected APRD FFT functions
--	1.4.5 
--		Fixed the combo_tape function to take tx/rx ports into account
--	1.4.4 
--		Fixed a bug in the frequency slice function to make it actually work
--		Fixed a bug in the background subtraction function that was causing the bg subtracted scans to not be correct
--		Changed the variable types of some of the parameters in the dialog menu
-- 		Disabled the option to additionally output background subtraction of the average background from the average frame from the input file(s)
--		Disabled the file overwrite protection due to some error when trying to overwrite a file
--	1.4.3 
--		Added explicit call to garbage collect after processing each file
--	1.4.2 
--		Fixed a bug in the background subtraction function that would mess up on incomplete frames
--		Consolidated the file output functions
--	1.4.1 
--		Added statistical comparison
--		Fixed a bug that caused APRD to crash if you execute a forms.error in the verify function
--	1.4.0 
--		Added position data extraction capability 
--		Updated the time window function to be more efficient
--		Removed option to convert files to HEX format
--		Removed the selective scan data extraction
--		Removed the combination extraction
--		Reorganized and updated labeling of processing options in dialog window

---------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-File.lua")
dofile("LuaProg/Lib-Tape.lua")
dofile("LuaProg/Lib-Type.lua")
dofile("LuaProg/Lib-Plot.lua")
---------------------------------------------

-- Conversion factor for converting sweep delay units from measurement units to seconds
-- Current firmware dictates 1 sweep delay unit = 1 millisecond
swDelayUnitConvFactor = 0.001

---------------------------------------------

function invalid_bound_params(start, stop, param_name, param_type)
	
	local err = false 
	
	if (start > stop) then
		forms.error("Invalid Start and Stop " .. param_type .. " for " .. param_name .."!")
		err = true
	end
	if (start < 0 or stop < 0) then
		forms.error("Invalid Start or Stop " .. param_type .. " for " .. param_name .."!")
		err = true
	end
	
	return err
end

function verify(params)
	
	local no_errors = true
	
	-- Check files
	if (params.proc_file1 == true) then
		if (FileExists(params.file1) == false) then
			forms.message("Invalid Data File #1!")
			no_errors = false
		end
	end

	if (params.proc_file2 == true) then
		if (FileExists(params.file2) == false) then
			forms.message("Invalid Data File #2!")
			no_errors = false
		end
	end

	if (params.proc_file3 == true) then
		if (FileExists(params.file3) == false) then
			forms.message("Invalid Data File #3!")
			no_errors = false
		end
	end

	if (params.out_alt == true) then
		if (DirExists(params.out_alt_dir) == false) then
			forms.message("Invalid Output Directory!")
			no_errors = false
		end
	end
	
	if (params.norm == true) then
		if (FileExists(params.norm_file) == false) then
			forms.message("Invalid Normalization File!")
			no_errors = false
		end
		if (params.norm_scan < 1) then
			form.error("Invalid Normalization Scan Number!")
			no_errors = false
		end
	end
	
	if (params.tw == true) then
		if(invalid_bound_params(params.tw_start, params.tw_stop, "Time Window", "Times")) then
			no_errors = false
		end
	end
	
	if (params.bg_sub == true) then
		if (FileExists(params.bg_file) == false) then
			forms.message("Invalid Background File!")
			no_errors = false 
		end
		if (params.bg_tw == true) then
			if (invalid_bound_params(params.bg_tw_start, params.bg_tw_stop, "BG Subtract Time Window", "Times")) then
				no_errors = false
			end
		end
		if (params.bg_conv == true) then
			if (params.bg_conv_delay < 0) then
				forms.message("Invalid Converter Delay!")
				no_errors = false
			end
		end
		if (params.bg_freq_range == true) then
			if (invalid_bound_params(params.bg_freq_range_start, params.bg_freq_range_stop, "BG Subtract Frequency Range", "Frequencies")) then
				no_errors = false
			end
		end
	end
	
	if (params.clip_back == true) then
		if (invalid_bound_params(params.clip_back_start, params.clip_back_stop, "Background Clip", "Frames")) then
			no_errors = false
		end
	end
	
	if (params.clip1 == true) then
		if (invalid_bound_params(params.clip1_start, params.clip1_stop, "Clip 1", "Frames")) then
			no_errors = false
		end
	end
	
	if (params.freq_range1 == true) then
		if (invalid_bound_params(params.freq_range_start1, params.freq_range_stop1, "Frequency Range", "Frequencies")) then
			no_errors = false
		end
	end
	
	return no_errors
end

-- Position Data Extraction
function init_gps_status (num_scans)

	local t = {
		init_northing = 0,
		init_easting = 0,
		total_dist = 0,
		northing_delta = V(num_scans),
		easting_delta = V(num_scans),
		vel_inst = V(num_scans),
		vel_avg = V(num_scans)
	}

	return t
end

function init_time_output (file, scan, UTC_T0) 
	local timestamp, frame_num, sweep_num = get_time_sweep_frame(scan)
	local UTC_T1 = UTC_T0 + timestamp
	file:write(
		string.format("%s\t%10.4f\t%4d\t%4d", os.date("%c", UTC_T1 + 16 * 3600), timestamp, frame_num, sweep_num))
	
	return timestamp
end

function InitEncOutput (file, enc_num, sensor_num, num_scans)
	
	local tape_enc = data_tape()
	if (params.filter_ports) then
		tape_enc = tape[function (x) return (x.RX == sensor_num+1 and x.TX_PORT == params.tx_port_num and x.RX_PORT == params.rx_port_num) end]
	else
		tape_enc = tape[function (x) return (x.RX == sensor_num+1) end]
	end
	
	if (#tape_enc == 0) then
		forms.error("NO ENCODER DATA FROM ENCODER " .. enc_num .. "!")
		num_scans = -1
	elseif (num_scans ~= 0) then 
		num_scans = math.min(num_scans, #tape_enc)
	else
		num_scans = #tape_enc
	end
		
	file:write("\tENC " .. enc_num .. " LEFT\tENC " .. enc_num .. " RIGHT")

	return tape_enc, num_scans
end

function get_encoder_scan_data (scan)

	local enc_left = scan.ENCODER_LSE
	local enc_right = scan.ENCODER_RSE
	
	return enc_left, enc_right
end

function get_time_sweep_frame (scan) 
	local timestamp = scan.TIMESTAMP
	local frame_num = scan.FRAME_NUMBER
	local sweep_num = scan.SWEEP_NUMBER
	
	return timestamp, frame_num, sweep_num
end

function get_gps_scan_data (scan)
	local heading = scan.GPS_HEADING
	local gps_week = scan.GPS_WEEK
	local gps_millisecond = scan.GPS_MILLISECOND
	local gps_sweep_delay = scan.SWEEP_DELAY
	local lat = scan.POS_LATITUDE
	local long = scan.POS_LONGITUDE
	local utm_northing = scan.UTM_NORTHING
	local utm_easting = scan.UTM_EASTING
	
	return heading, gps_week, gps_millisecond, gps_sweep_delay, lat, long, utm_northing, utm_easting
end

function calc_gps_stats (scan_curr, scan_prev, northing_init, easting_init, gps_tot_dist)
	local gps_northing_delta_curr = scan_curr.UTM_NORTHING - northing_init
	local gps_easting_delta_curr = scan_curr.UTM_EASTING - easting_init
	local gps_abs_pos_delta_curr = math.sqrt(gps_northing_delta_curr^2 + gps_easting_delta_curr^2)
	
	local gps_northing_delta_prev = scan_prev.UTM_NORTHING - northing_init
	local gps_easting_delta_prev = scan_prev.UTM_EASTING - easting_init
	local gps_abs_pos_delta_prev = math.sqrt(gps_northing_delta_prev^2 + gps_easting_delta_prev^2)
	
	local gps_tot_dist = gps_tot_dist + math.abs(gps_abs_pos_delta_curr - gps_abs_pos_delta_prev)
	
	local vel_inst = math.abs((gps_abs_pos_delta_curr - gps_abs_pos_delta_prev) / ((scan_curr.GPS_MILLISECOND - scan_prev.GPS_MILLISECOND) * 1.0e-3))
	-- local vel_inst = math.abs(gps_abs_pos_delta_curr - gps_abs_pos_delta_prev) / ((scan_curr.TIMESTAMP - (scan_curr.SWEEP_DELAY * swDelayUnitConvFactor)) - (scan_prev.TIMESTAMP - (scan_curr.SWEEP_DELAY  * swDelayUnitConvFactor)))
	local vel_avg = gps_tot_dist / (scan_curr.TIMESTAMP - (scan_curr.SWEEP_DELAY * swDelayUnitConvFactor))
	
	return gps_northing_delta_curr, gps_easting_delta_curr, gps_abs_pos_delta_curr, gps_tot_dist, vel_inst, vel_avg
end

function gps_extract (file, scanCurr, scanPrev, timestamp, i, gpsStatus, UTC_T0)

	if (timestamp == 0) then
		timestamp = init_time_output(file, scanCurr, UTC_T0) 
	elseif (math.abs(timestamp - scanCurr.TIMESTAMP) > 0.001) then
		print("WARNING - Time Stamp Mismatch! TS: " .. timestamp .. "\tTS ENC: " .. scanCurr.TIMESTAMP)
	end

	file:write(
		string.format("\t%10.2f\t%4d\t%4d\t%4d\t%14.8f\t%14.8f\t%10.2f\t%10.2f", get_gps_scan_data(scanCurr)) )

	if (i == 1) then
		gpsStatus.init_northing = scanCurr.UTM_NORTHING
		gpsStatus.init_easting = scanCurr.UTM_EASTING
		gpsStatus.northing_delta[i] = 0
		gpsStatus.easting_delta[i] = 0
		gps_abs_pos_delta = 0
		gpsStatus.vel_inst[i] = 0
		gpsStatus.vel_avg[i] = 0
	else
		gpsStatus.northing_delta[i], gpsStatus.easting_delta[i], gps_abs_pos_delta, gpsStatus.total_dist, gpsStatus.vel_inst[i], gpsStatus.vel_avg[i] 
			= calc_gps_stats(scanCurr, scanPrev, gpsStatus.init_northing, gpsStatus.init_easting, gpsStatus.total_dist)
			
		if (gpsStatus.vel_inst[i] == 0) then
			gpsStatus.vel_inst[i] = gpsStatus.vel_inst[i-1]
		end
	end

	file:write(
		string.format("\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.4f\t%10.4f", gpsStatus.northing_delta[i], gpsStatus.easting_delta[i], gps_abs_pos_delta, gpsStatus.total_dist, gpsStatus.vel_inst[i], gpsStatus.vel_avg[i]) )

	return timestamp, gpsStatus
end

function enc_extract (file, scan, timestamp, UTC_T0)
	if (timestamp == 0) then
		timestamp = init_time_output(file, scan, UTC_T0) 
	elseif (math.abs(timestamp - scan.TIMESTAMP) > 0.001) then
		print("WARNING - Time Stamp Mismatch! TS: " .. timestamp .. "\tTS ENC: " .. scan.TIMESTAMP)
	end
	
	file:write(
		string.format("\t%4d\t%4d", get_encoder_scan_data(scan)))
		
	return timestamp
end

function data_proc (data_file)
	
	tape = data_tape.read(data_file)
	local ND, F0, F1, SR = data_tape.get_scan_parameters(tape)
	
	if (params.out_alt) then
		local outDir = file.get_dir(params.out_alt_dir)
		local outDirABS = file.get_absolute(outDir)
		data_file = outDirABS .. "/" .. file.remove_dir(data_file)
	end
	
	if params.norm == true then
		local norm_tape = data_tape.read(params.norm_file)
		local nm_tape = NormTape(tape, norm_tape, params.norm_scan)
		DataFileOut(nm_tape, data_file, " - NORM")
	end

	if params.scale == true then
		local sc_tape = ScaleTape(tape, params.scale_factor)
		DataFileOut(sc_tape, data_file, " - SCALED x" .. params.scale_factor)
	end

	if params.tw == true then
		local tw_tape = TimeWindowTape(tape, params.tw_start, params.tw_stop, params.tw_hanning)
		DataFileOut(tw_tape, data_file, " - TW " .. params.tw_start .. "-" .. params.tw_stop .. "ns")
	end
	
	if params.bg_sub == true then
		local subTape = data_tape.read(params.bg_file)
		local bg_sub_tape = SubtractTape(tape, subTape)
		DataFileOut(bg_sub_tape, data_file, " - SUB")
	end
	
	if params.sub_run_avg == true then
		local subRunAvgTape = SubtractRunAvgTape(tape, params.sub_run_avg_nscans)
		DataFileOut(subRunAvgTape, data_file, " - RUN AVG SUB OF " .. params.sub_run_avg_nscans .. " SCANS")
	end
	
	if params.avg_frames == true then
		local avgTape = AvgTape(tape)
		DataFileOut(avgTape, data_file, " - AVG FRAME")
	end
	
	if params.min_max_freq == true then
		local minV, maxV = MinMaxTapeFreqDom(tape)

		local nPts, F0, F1 = data_tape.get_scan_parameters(tape)
		local xPts = V(#minV, F0, data_tape.get_freq_step(tape))
		local w = ChartTraces("ENVELOPE", "Frequency Domain", "Frequency (MHz)", "Magnitude (dB)", xPts, F0, F1, math.max(0, V.min(minV)), V.max(maxV), maxV, data_file, "Max", minV, data_file, "Min")
		
		ChartFileOut(w, data_file, " - MIN MAX FREQ")
	end
	
	if params.min_max_dist == true or params.min_max_time == true then
		local minV, maxV = MinMaxTapeTimeDom(tape)
		local timeStep = data_tape.get_time_step(tape, #minV)
		local distStep = timeStep / (2 * cInNanoSecPerM)
		local nPts = #minV
		local distCorrV = V(nPts, distStep, distStep)^params.min_max_dist_corr
		minV = minV * distCorrV
		maxV = maxV * distCorrV
		
		if params.min_max_time_db == true then
			chartYLabel = "Magnitude (dB)"
			minV = 20 * V.log10(minV)
			maxV = 20 * V.log10(maxV)
		else
			chartYLabel = "Magnitude"
		end
		
		sensTable = DT.get_sensor_table(tape)
		local maxTXDelayT = GetMaxTXDelay(sensTable)
		local maxRXDelayT = GetMaxRXDelay(sensTable)
		local maxCableDelayT = maxTXDelayT + maxRXDelayT
		local maxCableDelayD = maxCableDelayT / (2 * cInNanoSecPerM)
		
		if params.min_max_dist == true then
			local chartStepSize = distStep
			local cableDelay = maxCableDelayD
			local chartXLabel = "Distance (m)"
			local chartMaxX = chartStepSize * nPts - cableDelay
			local xPts = V(nPts, -cableDelay, chartStepSize)
			local w = ChartTraces("ENVELOPE", "Time Domain", chartXLabel, chartYLabel, xPts,
									chartStepSize, chartMaxX, math.max(0, V.min(minV)), V.max(maxV),
									maxV, data_file, "Max",
									minV, data_file, "Min")
			ChartFileOut(w, data_file, " - MIN MAX DIST")
		end
		
		if params.min_max_time == true then
			local chartStepSize = timeStep
			local cableDelay = maxCableDelayT
			local chartXLabel = "Time (ns)"
			local chartMaxX = chartStepSize * nPts - cableDelay
			local xPts = V(nPts, -cableDelay, chartStepSize)
			local w = ChartTraces("ENVELOPE", "Time Domain", chartXLabel, chartYLabel, xPts,
									chartStepSize, chartMaxX, math.max(0, V.min(minV)), V.max(maxV),
									maxV, data_file, "Max",
									minV, data_file, "Min")
			ChartFileOut(w, data_file, " - MIN MAX TIME")
		end
	end
	
	if params.snr == true then
		local fn, _ = ChopExtension(data_file)
		local snr_file = io.open(fn .. " - SNR.txt", "w")
		snr_file:write("SNR Measurement Results")
		snr_file:write("\n\nFilename: " .. data_file)
		snr_file:write("\nTarget Signal Distance: " .. params.snr_target_dist .. "m")
		snr_file:write("\nNoise Signal Distance: " .. params.snr_noise_dist .. "m")
		snr_file:write("\n\nCOMBO\tSNR (dB)")
		
		local comboTable = GetComboTable(tape)
		local SNRValues = V(#comboTable)
		for i = 1, #comboTable do
			local comboTape = GetComboTape(tape, comboTable[i].TX, comboTable[i].RX, comboTable[i].TX_PORT, comboTable[i].RX_PORT)
			local dataFreq = DT.get_matrix(comboTape)
			local dataTime = CM.fft(dataFreq, #dataFreq, true)
			
			local sensTable = DT.get_sensor_table(tape)
			local txDelay = sensTable[comboTable[i].TX].TX_DELAY
			local rxDelay = sensTable[comboTable[i].RX].RX_DELAY
			local delayDist = (txDelay + rxDelay) / (2 * cInNanoSecPerM)
			local timeStep = DT.get_time_step(tape, #dataTime[1])
				
			local targetRMS = CalcSigRMS(dataTime, params.snr_target_dist + delayDist, timeStep)
			local noiseRMS = CalcSigRMS(dataTime, params.snr_noise_dist + delayDist, timeStep)
			local SNR = 20*math.log10(targetRMS / noiseRMS)
			snr_file:write("\nTX(" .. comboTable[i].TX .. ")(" .. comboTable[i].TX_PORT .. ")"
							.. " RX(" .. comboTable[i].RX .. ")(" .. comboTable[i].RX_PORT .. ")"
							.. string.format("\t%.1f", SNR))
			SNRValues[i] = SNR
		end
		
		snr_file:write(string.format("\n\nAVERAGE SNR\t%.1f", V.avg(SNRValues)))
		
		snr_file:close()
	end
	
	if params.clip1 == true then
		local clip1_tape = GetClipTape(tape, params.clip1_start, params.clip1_stop)

		if(#clip1_tape == 0) then 
			forms.warning("Invalid start or stop frames specified to clip data file " .. data_file .. "! No file output.")
		else
			DataFileOut(clip1_tape, data_file, " - FRAMES " .. clip1_tape[1].FRAME_NUMBER .. "-" .. clip1_tape[#clip1_tape].FRAME_NUMBER)
		end
	end

	if params.clipN == true then
		local clipN_tape = GetLastNFramesClipTape(tape, params.clipN_nFrames)
		DataFileOut(clipN_tape, data_file, " - FRAMES " .. clipN_tape[1].FRAME_NUMBER .. "-" .. clipN_tape[#clipN_tape].FRAME_NUMBER)
	end
	
	if params.clipTS == true then
		local clipTS_tape = GetTSClipTape(tape, params.clipTS_start, params.clipTS_stop)
		if(#clipTS_tape == 0) then 
			forms.warning("Invalid start or stop times specified to clip data file " .. data_file .. "! No file output.")
		else
			local tSStart = string.format("%.0f", clipTS_tape[1].TIMESTAMP)
			local tSEnd = string.format("%.0f", clipTS_tape[#clipTS_tape].TIMESTAMP)
			DataFileOut(clipTS_tape, data_file, " - TS " .. tSStart .. "-" .. tSEnd)
		end
	end
	
	if params.clipTSN == true then
		local tSEnd = tape[#tape].TIMESTAMP
		local tSStart = tSEnd - params.clipTSNSeconds
		local clipTS_tape = GetTSClipTape(tape, tSStart, tSEnd)
		local tSStart = string.gsub(string.format("%.1f", clipTS_tape[1].TIMESTAMP), "%p", "p")
		local tSEnd = string.gsub(string.format("%.1f", clipTS_tape[#clipTS_tape].TIMESTAMP), "%p", "p")
		DataFileOut(clipTS_tape, data_file, " - TS " .. tSStart .. "-" .. tSEnd)
	end

	if params.freq_range1 == true then
		local freq1_tape, F0_out, F1_out = FreqSliceTape(tape, params.freq_range_start1, params.freq_range_stop1, params.freq_range_ex)

		F0_out = string.format("%.1f", F0_out)
		F1_out = string.format("%.1f", F1_out)
		
		if params.freq_range_ex then
			DataFileOut(freq1_tape, data_file, " - FREQ " .. string.gsub(F0_out, "%p", "p") .. "-" .. string.gsub(F1_out, "%p", "p") .. " EXCLUDED")
		else
			DataFileOut(freq1_tape, data_file, " - FREQ " .. string.gsub(F0_out, "%p", "p") .. "-" .. string.gsub(F1_out, "%p", "p"))
		end
	end
	
	if params.utm_correct then
		local utm_off_tape = data_tape()
		data_tape.copy_header(utm_off_tape, tape)
		for i = 1, #tape do
			local scan = tape[i]
			scan.UTM_EASTING = tape[i].UTM_EASTING + params.utm_easting_off
			scan.UTM_NORTHING = tape[i].UTM_NORTHING + params.utm_northing_off
			data_tape.append(utm_off_tape, scan)
		end
		DataFileOut(utm_off_tape, data_file, " - OFFSET UTM E " .. params.utm_easting_off .. " N " .. params.utm_northing_off)
	end

	if params.pos_data == true then
		local fn, _ = ChopExtension(data_file)
		local pos_file = io.open(fn .. " - POS DATA.txt", "w")
		pos_file:write(data_file .. "\n\nSYS UTC TIME\tTIMESTAMP\tFRAME\tSWEEP")
		
		local num_scans = 0
		
		local tape_gps1 = DT()
		if (params.gps_sensor1 == true) then
			if (params.filter_ports) then
				tape_gps1 = tape[function (x) return (x.RX == params.gps_sensor_num1+1 and x.TX_PORT == params.tx_port_num and x.RX_PORT == params.rx_port_num) end]
			else
				tape_gps1 = tape[function (x) return (x.RX == params.gps_sensor_num1+1) end]
			end
			
			pos_file:write("\tHEADING 1\tGPS WEEK 1\tGPS MILLISECOND 1\tGPS SWEEP DELAY 1\tLATITUDE 1\tLONGITUDE 1\tNORTHING 1\tEASTING 1\tNORTHING DELTA 1\tEASTING DELTA 1\tABS POS DELTA 1\tTOTAL DIST 1\tINSTANT VEL 1\tAVG TOT VEL 1")
			if (#tape_gps1 == 0) then
				forms.warning("NO GPS DATA FROM GPS SENSOR 1!")
				num_scans = -1
			else
				num_scans = #tape_gps1
			end
		end
		
		local tape_gps2 = DT()
		if (params.gps_sensor2 == true) then
			if (params.filter_ports) then
				tape_gps2 = tape[function (x) return (x.RX == params.gps_sensor_num2+1 and x.TX_PORT == params.tx_port_num and x.RX_PORT == params.rx_port_num) end]
			else
				tape_gps2 = tape[function (x) return (x.RX == params.gps_sensor_num2+1) end]
			end
			pos_file:write("\tHEADING 2\tGPS WEEK 2\tGPS MILLISECOND 2\tGPS SWEEP DELAY 2\tLATITUDE 2\tLONGITUDE 2\tNORTHING 2\tEASTING 2\tNORTHING DELTA 2\tEASTING DELTA 2\tABS POS DELTA 2\tTOTAL DIST 2\tINSTANT VEL 2\tAVG TOT VEL 2")
			if (#tape_gps2 == 0) then
				forms.warning("NO GPS DATA FROM GPS SENSOR 2!")
				num_scans = -1
			elseif (num_scans ~= 0) then 
				num_scans = math.min(num_scans, #tape_gps2)
			else
				num_scans = #tape_gps2
			end
		end

		local tape_enc1 = DT()
		if (params.enc1_extract) then
			tape_enc1, num_scans = InitEncOutput(pos_file, 1, params.enc1_sensor_num, num_scans, UTC_T0)
		end

		local tape_enc2 = DT()
		if (params.enc2_extract) then
			tape_enc2, num_scans = InitEncOutput(pos_file, 2, params.enc2_sensor_num, num_scans, UTC_T0)
		end

		local tape_enc3 = DT()
		if (params.enc3_extract) then
			tape_enc3, num_scans = InitEncOutput(pos_file, 3, params.enc3_sensor_num, num_scans, UTC_T0)
		end
		
		pos_file:write("\n")
		
		local UTC_T0 = data_tape.get_hardware_parameter_table(tape).TIME_SYNC
		
		local TS = V(num_scans)
		
		local gps_status1 = init_gps_status(num_scans)
		local gps_status2 = init_gps_status(num_scans)
		
		for i = 1, num_scans do
			
			TS[i] = 0
			
			if (params.gps_sensor1) then
				if (i == 1) then
					TS[i], gps_status1 = gps_extract(pos_file, tape_gps1[i], tape_gps1[i], TS[i], i, gps_status1, UTC_T0)
				else
					TS[i], gps_status1 = gps_extract(pos_file, tape_gps1[i], tape_gps1[i-1], TS[i], i, gps_status1, UTC_T0)
				end
			end

			if (params.gps_sensor2) then
				if (i == 1) then
					TS[i], gps_status2 = gps_extract(pos_file, tape_gps2[i], tape_gps2[i], TS[i], i, gps_status2, UTC_T0)
				else
					TS[i], gps_status2 = gps_extract(pos_file, tape_gps2[i], tape_gps2[i-1], TS[i], i, gps_status2, UTC_T0)
				end
			end
			
			if (params.enc1_extract) then
				TS[i] = enc_extract(pos_file, tape_enc1[i], TS[i])
			end
			
			if (params.enc2_extract) then
				TS[i] = enc_extract(pos_file, tape_enc2[i], TS[i])
			end
			
			if (params.enc3_extract) then
				TS[i] = enc_extract(pos_file, tape_enc3[i], TS[i])
			end
			
			pos_file:write("\n")
		end
		
		pos_file:close()
		
		print ("\n------------------------------------")
		print ("File Output:", fn .. " - POS DATA.txt")
		print ("------------------------------------\n")
	end
	
	if params.header == true then
		OutputHeader(data_file)
	end
	
	if params.start_file == true then
		
		data_source.set_type(DATA_FILE)
		data_source.set_filename(data_file)
		
		local start_tape = data_source.collect(params.stop_time, MULTI_FRAME)
		
		local start_filename, ext = ChopExtension(data_file) 
		start_filename = start_filename .. " - CLIP - TIME 0-" .. params.stop_time .. " SEC" .. ext
		data_tape.write(start_tape, start_filename)
	end
	
	if params.out_ascii == true then
		DataFileOut(tape, data_file, "CONV_FORMAT_ASCII")
	end
	
	if params.out_bin == true then
		DataFileOut(tape, data_file, "CONV_FORMAT_BIN")
	end
	
	if params.out_start_stop == true then
		local T0 = data_tape.get_hardware_parameter_table(tape).TIME_SYNC
		local T1 = tape[#tape].TIMESTAMP + T0
		-- UTC_T0 = UTC_T0 + (3600 * 8) -- 8 HOUR OFFSET CORRECTION
		-- UTC_T1 = UTC_T1 + (3600 * 8) -- 8 HOUR OFFSET CORRECTION
		window_manager.append_text(W_START_STOP, "\n" .. file.remove_dir(data_file) .. os.date("\t%X", T0) .. os.date("\t%X", T1))
	end

	collectgarbage()
end

dofile("LuaProg/Tool-Data-Proc-Dialog.lua")
 
params = get_parameters()

if params == nil then error() end

if (params.out_start_stop == true) then
	W_START_STOP = window_manager.make(FL_EDITOR_WINDOW, false)
	window_manager.append_text(W_START_STOP, "FILENAME\tSTART TIME\tSTOP TIME")
end

-- if params.snr then
	-- W_SNR = window_manager.make(FL_EDITOR_WINDOW, false)
	-- window_manager.append_text(W_SNR, "FILENAME\tCOMBO\tSNR (dB)")
-- end

if (params.proc_file1) then
	data_proc(params.file1)
end

if (params.proc_file2) then
	data_proc(params.file2)
end

if (params.proc_file3) then
	data_proc(params.file3)
end

if (params.proc_file_dir) then
	local x = file.get_directory_structure(params.file_dir, true)
	for k in pairs(x) do
		local src = x[k].ABSOLUTE
		if IsDataFile(src) then
			data_proc(src)
		end
	end	
end

print("\n-------------------")
print("Processing Complete")
print("-------------------\n")
forms.message("Processing Complete")
