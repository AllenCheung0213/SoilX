--
-- Tool-Envelope-Tape.lua
--

-- Calculates and displays the minimum and maximum envelope of the entire tape in a single analysis window.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

 M = matrix
CM = complex_matrix

-- SOURCE_NAME is bound to the analysis window
-- that called this script. We can access the window
-- and its contents using it.

-- However, this script can be used stand alone by testing SOURCE_NAME
-- and assuming the data is located globally in the data source.

if SOURCE_NAME == "" then
	m = data_source.get_matrix()

	NF, F0, F1, SR = data_source.get_scan_parameters(SOURCE_NAME)

	dF = data_source.get_freq_step()
	T1 = data_source.get_filename()
else
	-- Get all the lines in a single matrix and
	-- calculate the average line.
	m = chart.get_matrix(SOURCE_NAME)

	-- The assumption is that the chart is an analysis
	-- window and has the scan parameters we need
	-- for creating a new window with the same properties.
	NF, F0, F1, SR = chart.get_scan_parameters(SOURCE_NAME)

	dF = chart.get_freq_step(SOURCE_NAME)
	T1 = chart.get_title2(SOURCE_NAME)
end

---------------------------------------------
---------------------------------------------
-- Convert the rows to decibels
m = CM.dec(m)

-- min, avg and max operate on the columns of the matrix -- no
-- need to transpose.
MIN = M.min(m)
AVG = M.avg(m)
MAX = M.max(m)

X_AXIS = V(NF, F0, dF)

-- Make a new analysis window.
if SOURCE_NAME == "" then
	wn  = window_manager.make_name()
else
	wn = SOURCE_NAME .. "(NVLP)"
	window_manager.register(SOURCE_NAME, PROGRAM_NAME, wn)
end


w = chart(wn, FL_CHART_WINDOW)
chart.clear(w)

-- Tranfer the scan parameters.
--chart.set_scan_parameters(w, NF, F0, F1, SR)

-- Add the vectors.
chart.add(w, X_AXIS, MIN, "Minimum", T1)
chart.add(w, X_AXIS, MAX, "Maximum", T1)
chart.add(w, X_AXIS, AVG, "Average", T1)

chart.update(w)




