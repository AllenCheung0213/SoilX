-- REV DATE: 02/23/10

L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector
CM = complex_matrix
 M = matrix

function Initialize()
	maxV = V()
	minV = V()
	
	W1 = chart("ENVELOPE", "Time Domain - Min/Max", FL_CHART_WINDOW)
	chart.set_xlabel(W1, "FFT Points")
	chart.set_ylabel(W1, "Magnitude")
	chart.update(W1)
	
	initScan = true
	easterEgg1 = true
	easterEgg2 = true
	
	numScans = 0
end

function Process(scan)
	numScans = numScans + 1
	
	local freqData = scan.DATA
	local fftData = CV.fft(freqData, 2 * #freqData)
	fftDataMag = CV.abs(fftData)
	
	if (initScan) then
		maxV = fftDataMag
		minV = fftDataMag
		initScan = false
	else
		maxCompareM = M()
		M.append(maxCompareM, maxV)
		M.append(maxCompareM, fftDataMag)
		maxV = M.max(maxCompareM)
		
		minCompareM = M()
		M.append(minCompareM, minV)
		M.append(minCompareM, fftDataMag)
		minV = M.min(minCompareM)
	end
	
	xPts = V(#fftData, 1, 1)
	
	chart.clear(W1)
	bound1 = 3600
	bound2 = 28800
	
	if (scan.TIMESTAMP < bound1) then
		chart.add(W1, xPts, fftDataMag, "Frame: " .. scan.FRAME_NUMBER .. " Sweep: " .. scan.SWEEP_NUMBER
									.. " TX(" .. scan.TX-1 .. ")(" .. scan.TX_PORT .. ")"
									.. " RX(" .. scan.RX-1 .. ")(" .. scan.RX_PORT .. ")"
									.. " TS: " .. string.format("%.2f",scan.TIMESTAMP),
									"# Scans Processed: " .. numScans)
	elseif (scan.TIMESTAMP >= bound1 and scan.TIMESTAMP <= bound2) then
		chart.add(W1, xPts, fftDataMag, "Frame: " .. scan.FRAME_NUMBER .. " Sweep: " .. scan.SWEEP_NUMBER
									.. " TX(" .. scan.TX-1 .. ")(" .. scan.TX_PORT .. ")"
									.. " RX(" .. scan.RX-1 .. ")(" .. scan.RX_PORT .. ")"
									.. " TS: " .. string.format("%.2f",scan.TIMESTAMP),
									"# Scans Processed: " .. numScans .. " - You're doing a great job!")		
		if (easterEgg1) then
			print("\n\nCongratulations! You've been collecting data for over an hour! You are such a good worker!" )
			easterEgg1 = false
		end
	elseif (scan.TIMESTAMP > bound2 and easterEgg2) then
		chart.add(W1, xPts, fftDataMag, "Frame: " .. scan.FRAME_NUMBER .. " Sweep: " .. scan.SWEEP_NUMBER
									.. " TX(" .. scan.TX-1 .. ")(" .. scan.TX_PORT .. ")"
									.. " RX(" .. scan.RX-1 .. ")(" .. scan.RX_PORT .. ")"
									.. " TS: " .. string.format("%.2f",scan.TIMESTAMP),
									"# Scans Processed: " .. numScans .. " - Excellent Work! Someone is due a promotion!")
		if (easterEgg2) then
			print("\n\nWoW! You've now passed 8 hours of data collection! Someone is due a promotion!" )
			easterEgg2 = false
		end
	end
	
	chart.add(W1, xPts, maxV, "Max")
	chart.add(W1, xPts, minV, "Min")
	
	chart.update(W1)
end
