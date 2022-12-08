-- Title: Radar Specific Functions
-- Filename: Lib-Radar.lua
-- Description: Functions for radar related problems
-- Version 1.3.0, 04/22/2011
-- Author: Patton Gregg
-- Revision History:
--	1.3.0, 04/22/2011
--		Added FFTZeroFill function
--		Fixed bug in GetMotionComponent and GetMotionComponentPeak that averaged the return data incorrectly
--	1.2.10, 03/22/2011
--		Updated Get2DFFT to use CM.fft2 for the second FFT
--		Fixed bug in GetAvgScanTime caused by Lib-Tape not being included, and extracting timestamps from the wrong variable
--	1.2.9, 03/18/2011
--		Fixed bug in GetMotionComponent that didn't select the right frequencies
--		Fixed bug in Get2DFFT what incorrectly truncated the frequency data matrix
--	1.2.8, 03/11/2011
--		Added parameters to Get2DFFT to allow to specify number of FFT points and select whether zero fill and/or windowing are performed
--	1.2.7, 01/27/2011
--		Fixed bug in CalcSigRMS
--	1.2.6, 01/20/2011
-- 		Fixed some bugs in using GenTargetResp
-- 		Updated TDD Gate Calculator functions to allow for gate parameters calculated for maximum duty cycle
--	1.2.5, 01/19/2011
--		Updated TDD Gate Calculator functions to integrate additional hardware delays which had been unaccounted for 
--	1.2.4, 01/17/2011
--		Fixed bug where the minimum clock for the gate value for RX2-TX1 was assumed to be 4 instead of 3 clock cycles
--	1.2.3, 01/13/2011
--		Fixed bug in GetTargetResp
--	1.2.2, 01/12/2011
--		Updated GetMaxAntDist, GetMaxTXDelay, and GetMaxRXDelay to calculate values using only enabled sensors
--	1.2.1, 01/11/2011
--		Deleted CalcTDDGateHarmon function
--		Added CalcSigRMS function
--		Added CalcDoppShift function
--	1.2.0, 12/22/2010
--		Added CalcPathLoss function
--		Added GetTargetResp function
--		Added CalcLambda function
--		Added CalcDoppFreqDelta function
--		Added CalcDoppFreqMax function
--		Added GetDCComponent function
--		Added GetMotionComponent function
--	1.1.1, 12/10/2010
--		Fixed bug in CheckGateDistParams where invalid gate parameters values were not corrected
--		Fixed various additional bugs in CheckGateDistParams that would provide the wrong correct values
--	1.1.0, 12/08/2010
--		Added GetGateParams
--		Added CheckGateDistParams
--	1.0.1, 12/08/2010
--		Fixed bug were math function library not included
--	1.0.0, 12/02/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-Math.lua")
-- dofile("LuaProg/Lib-Tape.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- CalcRangeRes (bandwidth) -> number
-- CalcMaxRange (freqStep) -> number
-- GetFreqIndex (freq, freq_step, F0) -> int
-- GetIndexFreq (index, freq_step, F0) -> number
-- GetTimeIndex (t, timeStep) -> int
-- GetIndexTime (index, timeStep) -> int
-- RoundToGateClock(pulseWidth) -> number
-- CalcGateParams (startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxDuty) -> 6 x number
-- CalcGateDist (txGate, txRxGateDelay, rx1Gate, rx2TxGateDelay, txCableDelay, rxCableDelay) -> 4 x number
-- GetGateParams (startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxDuty) -> 6 x number
-- CheckGateDistParams (startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxAntDist) -> 3 x number, error_string
-- GetMaxAntDist (sensTable) -> number
-- GetMaxTXDelay (sensTable) -> number
-- GetMaxRXDelay (sensTable) -> number
-- GetAvgScanTime(tape) -> number
-- CalcPathLoss(tx_gain, rx_gain, rcs, rcs_power, freq, dist, pow_r) -> number
-- GetTargetResp (dist, amp, f_start, f_step, num_pts) -> complex_vector
-- CalcLambda (freq) -> number
-- CalcAmp (dist, rcs, rcs_power, freq, tx_gain, rx_gain, tx_pow, loss_factor, rx_fs_pow, pow_r) -> number
-- CalcDoppFreqDelta (deltaT, nScans) -> number
-- CalcDoppFreqMax (deltaT) -> number
-- CalcDoppShift (freqMin, targetVel) -> number
-- FFTZeroFill (timeData, nFFTPts, freqStart, freqStop, nFreqPts)
-- Get2DFFT (tape, nFFT, zeroFill, window) -> complex_matrix
-- GetDCComponent(tape) -> complex_vector
-- GetMotionComponent(tape, minMotionFreq, maxMotionFreq) -> complex_vector
-- GetMotionComponentPeak(tape) -> complex_vector
--------------------------------------------------------
-- Range Functions
--------------------------------------------------------
-- Returns the range resolution for the specfied bandwidth
function CalcRangeRes (bandwidth)
	return (c / (2 * bandwidth))
end

-- Returns the maximum unambiguous range for the specified frequency step
function CalcMaxRange (freqStep)
	return (c / (2 * freqStep))
end

--------------------------------------------------------
-- Frequency Functions
--------------------------------------------------------
-- Returns the index location for a vector of frequency points with the given frequency step and start frequency
function GetFreqIndex (freq, freq_step, freq_start) 
	return (math.floor(((freq - freq_start) / freq_step) + 1))
end

-- Returns the frequency value for an index location from vector of frequency points with the given frequency step and start frequency
function GetIndexFreq (index, freq_step, freq_start) 
	return (freq_start + ((index - 1) * freq_step))
end

--------------------------------------------------------
-- Time Functions
--------------------------------------------------------
-- Returns the index location for a vector of time domain range bins with the given time step
function GetTimeIndex (t, timeStep) 
	return (math.floor(t / timeStep) + 1)
end

-- Returns the time for a index location from a vector of time domain range bins with the given time step
function GetIndexTime (index, timeStep) 
	return (index - 1) * timeStep
end

--------------------------------------------------------
-- TDD and Gating Functions
--------------------------------------------------------
-- Rounds the pulse width (ns) to the nearest TDD clock cycle
function RoundToGateClock(pulseWidth) return Round(pulseWidth / GateClock) * GateClock end

-- Returns the gate values for the desired signal distances
-- Note: Gate values are NOT guaranteed to not fall on a harmonic. For a more robust calculation of the gate
-- parameters, use GetGateParams function
function CalcGateParams (startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxDuty)
	
	local cableDelay = (txCableDelay + rxCableDelay)
	
	if (maxDuty) then
		startFullSigDist = endFullSigDist
	end
	
	tx1GateDelay = RoundToGateClock((2 * startSigDist * cInNanoSecPerM - 1.5 * GateClock) + (cableDelay))
	tx1Gate = RoundToGateClock((2 * startFullSigDist * cInNanoSecPerM) + (cableDelay) - (tx1GateDelay + 1.5 * GateClock))
	rx1Gate = RoundToGateClock((2 * endFullSigDist * cInNanoSecPerM) + (cableDelay) - (tx1GateDelay + 1.5 * GateClock)) + (3 * GateClock)
	rx2GateDelay = 3 * GateClock
	
	rx2Gate = 0
	rx1GateDelay = 0
	
	return tx1Gate, tx1GateDelay, rx1Gate, rx1GateDelay, rx2Gate, rx2GateDelay
end

-- Returns the range distances for the signal stop, start, and full power signal start, stop for the 
-- specified gate values
function CalcGateDist (txGate, txRxGateDelay, rx1Gate, rx2TxGateDelay, txCableDelay, rxCableDelay)
	
	local rx1Gate = rx1Gate - (3 * GateClock)
	local txRxGateDelay = txRxGateDelay + (1.5 * GateClock)
	
	startSigDist = (txRxGateDelay - (txCableDelay + rxCableDelay)) / (2 * cInNanoSecPerM)
	startFullSigDist = (txGate + txRxGateDelay - (txCableDelay + rxCableDelay)) / (2 * cInNanoSecPerM)
	endFullSigDist = (txRxGateDelay + rx1Gate - (txCableDelay + rxCableDelay)) / (2 * cInNanoSecPerM)
	endSigDist = (txGate + rx1Gate + txRxGateDelay - (txCableDelay + rxCableDelay)) / (2 * cInNanoSecPerM)
	
	return startSigDist, startFullSigDist, endFullSigDist, endSigDist
end

-- Returns the gate values for the desired signal distances corrected to not fall on harmonics
function GetGateParams (startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxDuty)

	local tx1Gate, tx1GateDelay, rx1Gate, rx1GateDelay, rx2Gate, rx2GateDelay = CalcGateParams(startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxDuty)

	local gateValid = false
	while gateValid == false do
		local gateHarmon = false
		local period = (tx1Gate + tx1GateDelay + rx1Gate + rx1GateDelay + rx2Gate + rx2GateDelay)
		local pulseFreq = (1000 / period)
		for i = 1, 6 do
			local pulseFreqHarmon = i * pulseFreq
			if math.abs(pulseFreqHarmon - 10.7) <= GATE_CALC_IF_OFFSET then
				gateHarmon = true
			end
		end
		
		if gateHarmon then
			endFullSigDist = endFullSigDist + (GateClock / (2 * cInNanoSecPerM))
			tx1Gate, tx1GateDelay, rx1Gate, rx1GateDelay, rx2Gate, rx2GateDelay = CalcGateParams(startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxDuty)
		else
			gateValid = true
		end
	end
	
	return tx1Gate, tx1GateDelay, rx1Gate, rx1GateDelay, rx2Gate, rx2GateDelay
end

-- Checks the gate range values with the system parameters to check the values for errors and 
-- returns corrected range values with a string containing any error messages
function CheckGateDistParams (startSigDist, startFullSigDist, endFullSigDist, txCableDelay, rxCableDelay, maxAntDist)
	
	local errMsg = ""

	if startSigDist == nil then
		errMsg = errMsg .. "\nError! No Signal Start Distance specified!"
		startSigDist = 0
	end
	
	if startFullSigDist == nil then
		errMsg = errMsg .. "\nError! No Full Signal Start Distance specified!"
		startFullSigDist = 0
	end
	
	if endFullSigDist == nil then
		errMsg = errMsg .. "\nError! No Full Signal End Distance specified!"
		endFullSigDist = 0
	end
	
	if txCableDelay == nil then
		errMsg = errMsg .. "\nError! No TX Cable Delay specified!"
		txCableDelay = 0
	end
	
	if rxCableDelay == nil then
		errMsg = errMsg .. "\nError! No RX Cable Delay specified!"
		rxCableDelay = 0
	end
	
	if maxAntDist == nil then
		errMsg = errMsg .. "\nError! No Max Antenna Distance specified!"
		maxAntDist = 0
	end
	
	-- Error Check and Correct Values
	local txCableDelayDist = txCableDelay / cInNanoSecPerM
	local rxCableDelayDist = rxCableDelay / cInNanoSecPerM
	local cableDelayDist = txCableDelayDist + rxCableDelayDist
	local minTDDDelay = (4.5 * GateClock) / cInNanoSecPerM -- meters; equiv. to 3 TDD clock cycles
	-- local minTDDDelay = (3 * GateClock) / cInNanoSecPerM -- meters; equiv. to 3 TDD clock cycles
	
	local minDist = math.max((minTDDDelay - cableDelayDist) / 2, maxAntDist / 2)

	if startSigDist < minDist then
		errMsg = errMsg .. "\nError! Signal Start Distance must be at least " .. string.format("%.1f m!", math.max(0, minDist+0.1))
		startSigDist = minDist
	end

	-- Minimum ramp length determine by a min. of 4 clock cycles for the TX gate
	--	and 1.5 clock cycles off time during the switching of the RX gate
	local min_ramp_length = (4 * GateClock) / (2 * cInNanoSecPerM)
	-- local min_ramp_length = (4 * GateClock - 1.5 * GateClock) / (2 * cInNanoSecPerM)
		
	if startFullSigDist < startSigDist + min_ramp_length  then
		errMsg = errMsg .. "\nError! Full Signal Start Distance must be at least " .. 
				string.format("%.1f", min_ramp_length + 0.1) ..
				" m greater than Signal Start Distance"
		startFullSigDist = startSigDist + min_ramp_length
	end
	
	if startFullSigDist > endFullSigDist then
		errMsg = errMsg .. "\nError! Full Signal Start Distance greater than Full Signal End Distance!"
		endFullSigDist = startFullSigDist
	end
	
	return startSigDist, startFullSigDist, endFullSigDist, errMsg
end

--------------------------------------------------------
-- Sensor Functions
--------------------------------------------------------
-- Returns the maximum distance between active elements for the given sensor table
function GetMaxAntDist (sensTable)
	
	local maxDist = 0
	
	for j = 1, #sensTable do
		for k = 2, #sensTable do
			if sensTable[j].TX == true and sensTable[k].RX == true then
				local x1 = sensTable[j].X
				local y1 = sensTable[j].Y
				local z1 = sensTable[j].Z
				local x2 = sensTable[k].X
				local y2 = sensTable[k].Y
				local z2 = sensTable[k].Z
				local dist = Dist3D(x1, y1, z1, x2, y2, z2)
				if dist > maxDist then
					maxDist = dist
				end
			end
		end
	end

	return maxDist
end

-- Returns the maximum transmit cable delay for the active transmitting elements for the given sensor table
function GetMaxTXDelay (sensTable)
	
	local maxTXDelay = 0
	
	for i = 1, #sensTable do
		if sensTable[i].TX_DELAY > maxTXDelay and sensTable[i].TX == true then
			maxTXDelay = sensTable[i].TX_DELAY
		end
	end
	
	return maxTXDelay	
end

-- Returns the maximum receive cable delay for the active receiving elements for the given sensor table
function GetMaxRXDelay (sensTable)
	
	local maxRXDelay = 0
	
	for i = 1, #sensTable do
		if sensTable[i].RX_DELAY > maxRXDelay and sensTable[i].RX == true then
			maxRXDelay = sensTable[i].RX_DELAY
		end
	end
	
	return maxRXDelay	
end

-- Returns the average time, in seconds, between scans
function GetAvgScanTime(tape)

	local comboTape = GetComboTape(tape, tape[1].TX, tape[1].RX, tape[1].TX_PORT, tape[1].RX_PORT)

	local ts = comboTape[TIMESTAMP]
	local deltaTS = V.slice(ts, 2, #ts) - V.slice(ts, 1, #ts - 1)
	local avgScanTime = V.avg(deltaTS)

	return avgScanTime
end

--------------------------------------------------------
-- Radar Signal Functions
--------------------------------------------------------
-- Calculates the expected two-way path loss for the specified values
function CalcPathLoss(tx_gain, rx_gain, rcs, rcs_power, freq, dist, pow_r)

	local path_loss = 10*math.log10((tx_gain * rx_gain * rcs^(rcs_power) * CalcLambda(freq)^2) / ((4*math.pi)^3 * dist^(pow_r)))
	
	return path_loss
end

-- Returns the expected response that would be seen by the radar for a target
function GetTargetResp (dist, amp, f_start, f_step, num_pts)

	local t = dist / c
	local freq = V(num_pts, f_start, f_step) * 1e6
	local phase = 2 * math.pi * freq * t
	local echo_i = amp * V.cos(phase)
	local echo_q = -amp * V.sin(phase)
	-- local echo_i = -amp * V.sin(phase)
	-- local echo_q = amp * V.cos(phase)
	local echo = CV(echo_i, echo_q)
	
	-- local win_multi = 0.5 * (1 - math.cos(2.0 * math.pi * (i-1) /(num_pts-1)));
	-- echo_win = echo * win_multi

	return echo
	-- return echo_win
end

-- Returns the wavelength for a given frequency
function CalcLambda (freq)
	return c / freq
end

-- Returns the expected amplitude of a target signal
function CalcAmp (dist, rcs, rcs_power, freq, tx_gain, rx_gain, tx_pow, loss_factor, rx_fs_pow, pow_r)

	local pow_rx = tx_pow + CalcPathLoss(tx_gain, rx_gain, rcs, rcs_power, freq, dist, pow_r) + 10*math.log10(loss_factor)		
	-- rx_pow_fs_mw = 10^(rx_fs_pow/10) -- convert rx full-scale power from db to milli-watts

	return 1000*10^(pow_rx/10)
end

--------------------------------------------------------
-- Signal Processing Functions
--------------------------------------------------------
-- Returns the doppler frequency delta
function CalcDoppFreqDelta (deltaT, nScans) 
	return 1 / (deltaT * nScans)
end

-- Returns the maximum doppler frequency for a given time step between scans
function CalcDoppFreqMax (deltaT) 
	return 1 / (2 * deltaT)
end

-- Returns the expected doppler shift
function CalcDoppShift (freqMin, targetVel)
	return (2 * targetVel * freqMin) / c
end

-- Transforms time domain data, that had been zero filled, back to the frequency
-- domain, and return only the valid frequency data (i.e. no zeroed data)
function FFTZeroFill (timeData, nFFTPts, freqStart, freqStop, nFreqPts)

	local freqStep = (freqStop - freqStart) / (nFreqPts - 1)
	local nZeros = math.floor(freqStart / freqStep)

	local freqData
	if L.is_complex_vector(timeData) then
		freqData = CV.fft(timeData, nFFTPts, false, false)
		freqData = CV.slice(freqData, nZeros + 1, nZeros + nFreqPts)
	else
		freqData = CM.fft(timeData, nFFTPts, false, false)
		freqData = CM.slice2(freqData, nZeros + 1, nZeros + nFreqPts)
	end

	return freqData
end

-- Returns a matrix result for the 2D FFT of a tape
function Get2DFFT (tape, nFFT, zeroFill, window)
	
	local nFFTPts = 0

	local freq_matrix = data_tape.get_matrix(tape)
	local nScan = Order2N(N2OrderFloor(#tape))
	freq_matrix = CM.slice(freq_matrix, (#freq_matrix - nScan)+1)

	local time_matrix = CM()
	if (zeroFill) then
		local nPoints, F0, F1, SR = data_tape.get_scan_parameters(tape)
		local fStep = data_tape.get_freq_step(tape)
		nFFTPts = Order2N(N2Order(F1 / fStep))
		if (nFFT > nFFTPts) then
			nFFTPts  = Order2N(N2Order(nFFT))
		end
		time_matrix = CM.fft(freq_matrix, nFFTPts, F0, F1, window, true)
	else
		nFFTPts = Order2N(N2Order(nFFT))
		time_matrix = CM.fft(freq_matrix, nFFTPts, window, true)
	end
	
	-- local doppler_matrix = CM.fft2(time_matrix, nScan)
	local doppler_matrix = CM.transpose(time_matrix)
	doppler_matrix = CM.fft(doppler_matrix, nScan, false, false)
	doppler_matrix = CM.transpose(doppler_matrix)
	
	return doppler_matrix
end

-- Returns the DC component from a tape
function GetDCComponent (tape)
	
	local nPoints, F0, F1, SR = data_tape.get_scan_parameters(tape)
	local fStep = data_tape.get_freq_step(tape)
	local nFFTPts = Order2N(N2Order(F1 / fStep))
	
	local zeroFillFFT = true
	local windowFFT = false
	local doppler_matrix = Get2DFFT(tape, nFFTPts, zeroFillFFT, windowFFT)
	
	-- Extract the DC component.
	local dc_component = doppler_matrix[1] 
	
	local freq_vector = FFTZeroFill(dc_component, nFFTPts, F0, F1, nPoints) / #doppler_matrix

	return freq_vector
end

-- Returns the sum of the components from a specified doppler frequency range from a 2D FFT
-- Frequencies specified in Hz
function GetMotionComponent (tape, minMotionFreq, maxMotionFreq)

	local nPoints, F0, F1, SR = data_tape.get_scan_parameters(tape)
	local fStep = data_tape.get_freq_step(tape)
	local nFFTPts = Order2N(N2Order(F1 / fStep))
	
	local doppler_matrix = Get2DFFT(tape, nFFTPts, true, false)
	
	-- Extract the Motion component
	-- Determine the doppler frequency values
	local deltaT = GetAvgScanTime(tape)
	local doppFreqDelta = CalcDoppFreqDelta(deltaT, #doppler_matrix)
	local doppFreqMax = CalcDoppFreqMax(deltaT)
	
	-- Calculate the row indices associated with the min and max doppler frequency ranges
	local iMinMotionFreqPos = math.min(math.floor(minMotionFreq / doppFreqDelta) + 2, #doppler_matrix)
	local iMaxMotionFreqPos = math.min(math.ceil(maxMotionFreq / doppFreqDelta) + 1, #doppler_matrix)
	local iMinMotionFreqNeg = math.min(#doppler_matrix - iMinMotionFreqPos + 2, #doppler_matrix)
	local iMaxMotionFreqNeg = math.min(#doppler_matrix - iMaxMotionFreqPos + 2, #doppler_matrix)

	-- Extract the negative and positive doppler frequency ranges
	local compPos = CM.slice(doppler_matrix, iMinMotionFreqPos, iMaxMotionFreqPos)
	local compNeg = CM.slice(doppler_matrix, iMaxMotionFreqNeg, iMinMotionFreqNeg)  

	-- Combine the negative and positive components
	local motion_component = compPos
	CM.append(motion_component, compNeg)
	
	local freqData = FFTZeroFill(motion_component, nFFTPts, F0, F1, nPoints)

	-- Get the average frequency components to conserve scale
	freqData = CM.sum(freqData) / #motion_component
	
	return freqData
end

-- Returns the sum of the peak components (other than the DC component) from a 2D FFT
function GetMotionComponentPeak (tape)

	local nPoints, F0, F1, SR = data_tape.get_scan_parameters(tape)
	local fStep = data_tape.get_freq_step(tape)
	local nFFTPts = Order2N(N2Order(F1 / fStep))

	local doppler_matrix = Get2DFFT(tape, #tape[1], true, false)
		
	local doppler_matrix_ABS = CM.abs(doppler_matrix)
	doppler_matrix_ABS[1] = V(#doppler_matrix_ABS[1], 0)

	-- Calculate a threashold for the peak find function
	local minVal, maxVal, avgVal, stdVal = M.stats(doppler_matrix_ABS)
	local peakThreas = avgVal + 3 * stdVal
	local peaks = M.ipp_find_peaks(doppler_matrix_ABS, peakThreas)
	local peakI = V.unique(CV.real(peaks))

	local motion_component = CV(#doppler_matrix[1], C(0,0))
	for i = 1, #peakI do
		motion_component = motion_component + doppler_matrix[peakI[i]]
	end

	local freqData = FFTZeroFill (motion_component, nFFTPts, F0, F1, nPoints)
	if L.is_complex_matrix(motion_component) then
		freqData = CM.sum(freqData) / #motion_component
	end

	return freqData
end
