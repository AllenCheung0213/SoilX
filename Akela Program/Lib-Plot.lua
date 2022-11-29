-- Title: Plotting Functions
-- Filename: Lib-Plot.lua
-- Description: Functions related to plotting
-- Version 1.0.0, 12/17/10
-- Author: Patton Gregg
-- Revision History:
--	1.0.0, 12/17/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- ChartTraces (chartType, chartName, xLabel, yLabel, xPts, xMin, xMax, yMin, yMax, ...) -> chart_handle
--------------------------------------------------------

-- Plots a chart with the traces specified
-- Usage: ChartTraces (chartType, chartName, xLabel, yLabel, xPts, xMin, xMax, yMin, yMax, <dataVector>, <dataLabel1>, <dataLabel2>)
-- Note: <dataVector>, <dataLabel1> and <dataLabel2> ALL REQUIRED for EACH trace that is to be plotted
function ChartTraces (chartType, chartName, xLabel, yLabel, xPts, xMin, xMax, yMin, yMax, ...)
	
	local w = chart(chartType, chartName, FL_CHART_WINDOW)
	chart.clear(w)
	chart.set_xlabel(w, xLabel)
	chart.set_ylabel(w, yLabel)
	
	-- chart.add(w, xPts, [dataV, dataLabel1, dataLabel2])
	for i = 1, arg.n, 3 do
		print("arg[i]", arg[i])
		chart.add(w, xPts, arg[i], arg[i+1], arg[i+2])
	end
	
	chart.set_scale(w, xMin, xMax, yMin, yMax)
	chart.update(w)
	
	return w
end
