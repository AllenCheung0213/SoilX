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
	
	W1 = chart("ENVELOPE", "Frequency Domain", FL_CHART_WINDOW)
	chart.set_xlabel(W1, "Frequency Point")
	chart.set_ylabel(W1, "Magnitude")
	chart.update(W1)
	
	initScan = true	
	
	numScans = 0
end

function Process(scan)
	numScans = numScans + 1
	
	local freqData = scan.DATA
	freqDataMag = 20 * V.log10(CV.abs(freqData))
	
	if (initScan) then
		maxV = freqDataMag
		minV = freqDataMag
		initScan = false
	else
		maxCompareM = M()
		M.append(maxCompareM, maxV)
		M.append(maxCompareM, freqDataMag)
		maxV = M.max(maxCompareM)
		
		minCompareM = M()
		M.append(minCompareM, minV)
		M.append(minCompareM, freqDataMag)
		minV = M.min(minCompareM)
	end
	
	xPts = V(#freqData, 1, 1)
	
	chart.clear(W1)
	chart.add(W1, xPts, freqDataMag, "Frame: " .. scan.FRAME_NUMBER .. " Sweep: " .. scan.SWEEP_NUMBER
										.. " TX(" .. scan.TX-1 .. ")(" .. scan.TX_PORT .. ")"
										.. " RX(" .. scan.RX-1 .. ")(" .. scan.RX_PORT .. ")"
										.. " TS: " .. string.format("%.2f",scan.TIMESTAMP),
										"# Scans Processed: " .. numScans)
	chart.add(W1, xPts, maxV, "Max")
	chart.add(W1, xPts, minV, "Min")
	
	chart.update(W1)
	
	
end
