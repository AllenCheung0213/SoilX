L = require("UTIL-Lua")
P = require("UTIL-Plot")

--------------------------------------------------------
CV = complex_vector
 V = vector

CM = complex_matrix

-- SOURCE_NAME is bound to the analysis window
-- that called this script. We can access the window
-- and its contents using it.

-- However, this script can be used standalone by testing SOURCE_NAME
-- and assuming the data is located globally in the data source.

if SOURCE_NAME == "" then
	m = data_source.get_matrix()

	NP, F0, F1, SR = data_source.get_scan_parameters(SOURCE_NAME)
else
	-- Get all the lines in a single matrix and
	-- calculate the average line.
	m = chart.get_matrix(SOURCE_NAME)

	if chart.is_analysis_window(SOURCE_NAME) then
		-- The assumption is that the chart is an analysis
		-- window and has the scan parameters we need
		-- for creating a new window with the same properties.
		NP, F0, F1, SR = chart.get_scan_parameters(SOURCE_NAME)
	else
		NP, F0, F1, SR = nil
	end
end

v = complex_matrix.avg(m)
title1 = string.format("Average of %d Scans", #m)

if SOURCE_NAME == "" then
	title2 = data_tape.get_filename(data_source.get_tape())
else
	title2 = chart.get_title2(SOURCE_NAME)
end

if SOURCE_NAME == "" then
	w = chart(FL_ANALYSIS_WINDOW)
	chart.set_analysis_parameters(w, NP, F0, F1, SR)
else
	-- CHILD_NAME is appended to the new window, making it a
	-- child of SOURCE_NAME.
	w = chart.spawn(SOURCE_NAME, CHILD_NAME)
end

-- Start all over.
chart.clear(w)

-- Add the average vector.
chart.add(w, v, title1, title2)
chart.update(w)

