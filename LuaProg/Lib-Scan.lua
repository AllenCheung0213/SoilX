-- Title: Scan Functions
-- Filename: Lib-Scan.lua
-- Description: Functions related to data scans 
-- Version 1.0.3, 02/02/2011
-- Author: Patton Gregg
-- Revision History:
--	1.0.3, 02/02/2011
--		Fixed bug in FreqSliceScan function that caused band exclusion to not work
--	1.0.2, 01/11/2011
--		Added functionality to exclude points in specified band for FreqSliceScan function
--	1.0.1, 12/16/2010
--		Change function name SliceFreqRange to FreqSliceScan
--	1.0.0, 11/30/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-Math.lua")
dofile("LuaProg/Lib-Radar.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- TimeWindowScan (scan, win_start, win_stop, freq_step, window_bool) -> scan
-- FreqSliceScan (scan, win_freq_start, win_freq_stop, data_freq_start, data_freq_step, exclude_band_bool) -> scan
--------------------------------------------------------

-- Returns a scan that has been time windowed
function TimeWindowScan (scan, win_start, win_stop, freq_step, window)
	
	local scan_size = #scan
	local fft_pts = 2 * scan_size

	local scan_fft = CV.fft(scan, fft_pts, window, true)
	
	fft_pts = #scan_fft
	local time_step = ((1*10^3) / (freq_step)) / (fft_pts)
	
	-- Zero fill all points outside of the time window
	local index_start = math.floor(win_start / time_step) + 1
	local index_stop = math.floor(win_stop / time_step) + 1
	
	local I = V(fft_pts, 1, 1)
	
	I = V.find(I, function(x) return x < index_start or x > index_stop end )
	
	scan_fft[I] = 0 
	
	local scan = CV.fft(scan_fft, fft_pts, false, false)
	scan = CV.truncate(scan, scan_size)

	return scan
end

-- Returns a scan that has had its frequency data sliced to the specified frequency band
function FreqSliceScan (scan, win_freq_start, win_freq_stop, data_freq_start, data_freq_step, exclude_band)

	local index_start = GetFreqIndex(win_freq_start, data_freq_step, data_freq_start)
	local index_stop = GetFreqIndex(win_freq_stop, data_freq_step, data_freq_start)
	if exclude_band then
		local I = V(index_stop - index_start + 1, index_start, 1)
		local tempCV = scan.DATA
		tempCV[I] = C(0,0)
		scan.DATA = tempCV
	else
		scan.DATA = CV.slice(scan.DATA, index_start, index_stop)
	end

	return scan
end