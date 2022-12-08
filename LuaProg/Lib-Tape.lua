-- Title: Tape Functions
-- Filename: Lib-Tape.lua
-- Description: Functions related to data tapes
-- Version 1.1.3, 03/30/2011
-- Author: Patton Gregg
-- Revision History:
--	1.1.3, 03/30/2011
-- 		Added GetTSClipTape function to return a data tape over a specified time range
--	1.1.2, 01/27/2011
--		Added SubtractRunAvgTape function to subtract the running average from a data tape
--	1.1.1, 01/11/2011
--		Added functionality to exclude points in specified band for FreqSliceTape function
--		Updated TimeWindowTape to account for cable delays
--	1.1.0, 12/17/2010
--		Changed MinMax... functions to be more generalized and no longer generate chart windows
--	1.0.1, 12/16/2010
--		Added min_max_... functions from Tool-Data-Proc and renamed MinMaxTape...
--		Moved bg_sub function from Tool-Data-Proc and renamed SubtractTape 
--		Fixed a bug in SubtractTape that would ignore incomplete frames
--		Update to reflect change in function name SliceFreqRange to FreqSliceScan
--	1.0.0, 11/30/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-Scan.lua")
dofile("LuaProg/Lib-Math.lua")
dofile("LuaProg/Lib-Radar.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- AvgTape (tape) -> tape
-- FreqSliceTape (tape, frequency_start, frequency_stop, exclude_band_bool) -> tape
-- NormTape (tape, norm_tape, frame_number_for_norm_tape) -> tape
-- ScaleTape (tape, scale_factor) -> tape
-- SubtractTape (tape, subTape) -> tape
-- SubtractRunAvgTape (tape, nScans) -> tape
-- TimeWindowTape (tape, win_start, win_stop, window_bool) -> tape
-- GetClipTape (tape, frame_start, frame_stop) -> tape
-- GetTSClipTape (tape, timestamp_start, timestamp_stop) -> tape
-- GetLastNFramesClipTape (tape, nFrames) -> tape
-- GetComboTape (tape, tx, rx, tx_port, rx_port) -> tape
-- GetFrame (tape, frameNum) -> tape
-- GetComboTable (tape) -> table
-- GetClipTapeI (tape, frame_start, frame_stop) -> vector
-- GetComboTapeI (tape, tx, rx) -> vector
-- MinMaxTapeFreqDom (tape) -> min_vector, max_vector
-- MinMaxTapeTimeDom (tape) -> min_vector, max_vector
--------------------------------------------------------

-- Returns a tape of a single frame with the average of all the combos from the input tape
function AvgTape (tape)

	local avgTape = data_tape()
	data_tape.copy_header(avgTape, tape)
	
	local frame = GetLastNFramesClipTape(tape, 1)

	for i = 1, #frame do
		local comboTape = GetComboTape(tape, frame[i].TX, frame[i].RX, frame[i].TX_PORT, frame[i].RX_PORT)
		local scan = frame[i]
		scan.DATA = CM.avg(DT.get_matrix(comboTape))
		data_tape.append(avgTape, scan)
	end

	return avgTape
end

-- Returns a tape with frequency data that has been sliced for a specified frequency band
function FreqSliceTape (tape, freq_start, freq_stop, exclude_band)

	local nPts, F0, F1, SR = data_tape.get_scan_parameters(tape)
	local freq_step = data_tape.get_freq_step(tape)
	
	-- Get data from tape
	local tape_out = data_tape()
	data_tape.copy_header(tape_out, tape)
	
	for i = 1, #tape do
		local scan = tape[i]
		data_tape.append(tape_out, FreqSliceScan(scan, freq_start, freq_stop, F0, freq_step, exclude_band))
	end

	F0_out = GetIndexFreq(GetFreqIndex(freq_start, freq_step, F0), freq_step, F0)
	F1_out = GetIndexFreq(GetFreqIndex(freq_stop, freq_step, F0), freq_step, F0)
	
	if exclude_band == false then
		data_tape.set_scan_parameters(tape_out, #tape_out[1], F0_out, F1_out, SR)
	end
	
	return tape_out, F0_out, F1_out
end

-- Returns a tape that is the output of having a tape normalized by a frame from another tape
function NormTape (tape, norm_tape, norm_frame)
	
	local norm_tape_frame = GetClipTape(norm_tape, norm_frame, norm_frame)

	if #data_tape.get_combo_table(tape) ~= #norm_tape_frame then
		forms.error("Error! Incomplete frame chosen for normalization frame!")
	end
	
	local tape_out = data_tape()
	data_tape.copy_header(tape_out, tape)
	for i = 1, #tape do
		local scan = tape[i]
		norm_tape_combo = GetComboTape(norm_tape_frame, scan.TX, scan.RX, scan.TX_PORT, scan.RX_PORT)
		scan.DATA = scan.DATA / norm_tape_combo[1].DATA
		data_tape.append(tape_out, scan)
	end  

	return tape_out
end

-- Returns a tape that is the a tape scaled by a specified factor
function ScaleTape (tape, scale_factor)

	local tape_out = data_tape()
	data_tape.copy_header(tape_out, tape)

	for i = 1, #tape do
		local scan = tape[i]
		scan.DATA = tape[i].DATA * scale_factor
		data_tape.append(tape_out, scan)
	end  
	
	return tape_out
end

-- Returns a tape that is the output of having the average of a tape subtracted from another tape
function SubtractTape (tape, subTape)
	
	print ("\n------------------------------------")
	print ("Data Subtraction Starting")
	print ("------------------------------------\n")
	local t0 = system.get_UTC_time()
	
	local nPts, F0, F1, SR = data_tape.get_scan_parameters(tape)
	local freq_step = data_tape.get_freq_step(tape)

	-- BACKGROUND DATA
	local subTapeAvg = AvgTape(subTape)
	local bg_avg_frame = data_tape.get_matrix(subTapeAvg)
	
	local newTape = data_tape()
	data_tape.copy_header(newTape, tape)
	
	local FR0 = tape[1].FRAME_NUMBER
	local FR1 = tape[#tape].FRAME_NUMBER
	local numFrames = FR1 - FR0 + 1
	
	-- Subtract AVG BG from Input Frames
	for j = FR0, FR1 do
		local tapeFrame = GetFrame(tape, j)
		
		for k = 1, #tapeFrame do
			local subTapeAvgCombo = GetComboTape(subTapeAvg, tapeFrame[k].TX, tapeFrame[k].RX, tapeFrame[k].TX_PORT, tapeFrame[k].RX_PORT)
			local newScan = tapeFrame[k]
			local newScanData = tapeFrame[k].DATA - subTapeAvgCombo[1].DATA
			newScan.DATA = newScanData
			data_tape.append(newTape, newScan)
		end
		
		if ((j - FR0 + 1) % 100 == 0) then
			print ("@" .. os.date("%H:%M:%S", system.get_UTC_time()) .. " - Finished with " .. (j - FR0 + 1) .. " out of " .. numFrames .. " frames.") 
		end
	end
	
	print("\n------------------------------------")
	print("Background Subtraction Run Time: ", system.get_UTC_time()-t0)
	print("------------------------------------\n")
	return newTape
end

-- Returns a tape that is the output of having the previous n scans subtracted from the each scan in a tape
function SubtractRunAvgTape (tape, nScans)
	
	print ("\n----------------------------------------------")
	print ("Running Average Data Subtraction Starting")
	print ("----------------------------------------------\n")
	local t0 = system.get_UTC_time()

	local dataTable = {}	
	local subRunAvgTape = DT()
	data_tape.copy_header(subRunAvgTape, tape)

	for i = 1, #tape do
		local combo = tape[i].TX .. tape[i].RX .. tape[i].TX_PORT .. tape[i].RX_PORT
		if dataTable[combo] == nil then
			DT.append(subRunAvgTape, tape[i])
			
			local tempCM = CM(1, #tape[i].DATA)
			tempCM[1] = tape[i].DATA
			dataTable[combo] = tempCM
		else
			local runAvgCV = CM.avg(dataTable[combo])
			local runAvgScan = tape[i]
			runAvgScan.DATA = tape[i].DATA - runAvgCV
			DT.append(subRunAvgTape, runAvgScan)
			
			CM.append(dataTable[combo], tape[i].DATA)
			if #dataTable[combo] > nScans then
				dataTable[combo] = CM.slice(dataTable[combo], #dataTable[combo] - nScans + 1, #dataTable[combo])
			end
		end
	end

	print ("\n----------------------------------------------")
	print ("Running Average Data Subtraction Finished In " .. string.format("%.2f", system.get_UTC_time()-t0) .. " Seconds")
	print ("----------------------------------------------\n")
	return subRunAvgTape
end

-- Returns a tape that has had the data time windowed
function TimeWindowTape (tape, win_start, win_stop, window)

	local sensTable = data_tape.get_sensor_table(tape)

	local tape_out = data_tape()
	data_tape.copy_header(tape_out, tape)

	local freq_step = data_tape.get_freq_step(tape)
	
	for i = 1, #tape do
		local scan = tape[i]
		local txDelay = sensTable[scan.TX].TX_DELAY
		local rxDelay = sensTable[scan.RX].RX_DELAY
		local cableDelay = txDelay + rxDelay
		scan.DATA = TimeWindowScan(scan.DATA, win_start + cableDelay, win_stop + cableDelay, freq_step, window)
		data_tape.append(tape_out, scan)
	end
	
	return tape_out
end

-- Returns a tape of only the specified range of frames
function GetTSClipTape (tape, timestamp_start, timestamp_stop)
	
	if (timestamp_start > timestamp_stop) then
		local temp = timestamp_start
		timestamp_start = timestamp_stop
		timestamp_stop = temp
	elseif (timestamp_stop == nil) then
		timestamp_stop = tape[#tape].TIMESTAMP
	end
	
	return tape[function (x) return x.TIMESTAMP >= timestamp_start 
								and x.TIMESTAMP <= timestamp_stop end]
end

-- Returns a tape of only the specified range of frames
function GetClipTape (tape, frame_start, frame_stop)
	
	if (frame_start > frame_stop) then
		local temp = frame_start
		frame_start = frame_stop
		frame_stop = temp
	elseif (frame_stop == nil) then
		frame_stop = frame_start
	end
	
	return tape[function (x) return x.FRAME_NUMBER >= frame_start 
								and x.FRAME_NUMBER <= frame_stop end]
end

-- Returns a tape of only the last N frames
function GetLastNFramesClipTape (tape, nFrames)

	local comboTable = data_tape.get_combo_table(tape)
	local nCombos = #comboTable
	local frameEnd = tape[#tape].FRAME_NUMBER
	local frameStart = math.max(frameEnd - nFrames + 1, 1)
	local clipN_tape = GetClipTape(tape, frameStart, frameEnd)

	while (nCombos * (frameEnd - frameStart + 1) ~= #clipN_tape and frameEnd >= 1) do
		frameEnd = frameEnd - 1
		frameStart = math.max(frameEnd - nFrames + 1, 1)
		clipN_tape = GetClipTape(tape, frameStart, frameEnd)
	end
	
	return clipN_tape
end

-- Returns a tape of only the specified combinations
function GetComboTape (tape, tx, rx, tx_port, rx_port)

	return tape[function (x) return x.TX == tx 
								and x.RX == rx
								and x.TX_PORT == tx_port
								and x.RX_PORT == rx_port end]
end

-- Returns a tape of a single specified frame
function GetFrame (tape, frameNum)
	return tape[function (x) return x.FRAME_NUMBER == frameNum end]
end

-- Returns a table of all valid combinations in the input tape
function GetComboTable (tape)
	
	-- The built in get_combo_table function does not return PORT assignments
	-- This variable is used just to ensure we have the same number of scans in the frame we get
	local ct = data_tape.get_combo_table(tape)
	numScans = #ct
	
	local singleFrame = GetLastNFramesClipTape(tape, 1)
	
	local comboTable = {}
	for i = 1, #singleFrame do
		comboTable[i] = {}
		comboTable[i].TX = singleFrame[i].TX
		comboTable[i].RX = singleFrame[i].RX
		comboTable[i].TX_PORT = singleFrame[i].TX_PORT
		comboTable[i].RX_PORT = singleFrame[i].RX_PORT
	end	

	return comboTable
end

-- Returns a vector of scan indexes for the specfied range of frames
function GetClipTapeI (tape, frame_start, frame_stop)
	
	local I = V(#tape, 1, 1)
	V.find(I, function (i) return tape[i].FRAME_NUMBER >= frame_start and tape[i].FRAME_NUMBER <= frame_stop end)

	return I
end

-- Returns a vector of scan indexes for scans of the specified TX-RX combination
function GetComboTapeI (tape, tx, rx)

	local I = V(#tape, 1, 1)
	V.find(I, function (i) return tape[i].TX == tx+1 and tape[i].RX == rx+1 end)
	
	return I
end

-- Returns the vectors for the minimum and maximum frequency values for the input tape
function MinMaxTapeFreqDom (tape)

	local maxCompareM = M(2, #tape[1].DATA)
	local minCompareM = M(2, #tape[1].DATA)
	local freqData = nil
	local freqDataMag = nil
	local maxV = V()
	local minV = V()

	if #tape < 1000 then
		freqData = data_tape.get_matrix(tape)
		freqDataMag = 20 * M.log10(CM.abs(freqData))
		maxV = M.max(freqDataMag)
		minV = M.min(freqDataMag)
	else 
		for i = 1, #tape do
			freqData = tape[i].DATA
			freqDataMag = 20 * V.log10(CV.abs(freqData))
			minV, maxV = MinMaxCompareV(freqDataMag, minV, maxV)
		end
	end
	
	return minV, maxV
end

-- Returns the vectors for the minimum and maximum range values for the input tape
function MinMaxTapeTimeDom (tape)
	
	local fftPts = Order2N(N2Order(#tape[1] * 2))
	local maxCompareM = M(2, fftPts)
	local minCompareM = M(2, fftPts)
	local freqData = V(fftPts)
	local fftData = V(fftPts)
	local fftDataMag = V(fftPts)
	local maxV = V(fftPts)
	local minV = V(fftPts)
	
	if #tape < 1000 then
		freqData = data_tape.get_matrix(tape)
		fftData = CM.fft(freqData, fftPts, true, true)
		fftDataMag = CM.abs(fftData)
		maxV = M.max(fftDataMag)
		minV = M.min(fftDataMag)
	else 
		for i = 1, #tape do
			freqData = tape[i].DATA
			fftData = CV.fft(freqData, fftPts, true, true)
			fftDataMag = CV.abs(fftData)
			minV, maxV = MinMaxCompareV(fftDataMag, minV, maxV)
		end
	end
	
	return minV, maxV
end


