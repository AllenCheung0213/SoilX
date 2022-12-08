L = require("UTIL-Lua")
P = require("UTIL-Plot")

--------------------------------------------------------
CV = complex_vector
 V = vector

CM = complex_matrix
 M = matrix

-- SOURCE_NAME is bound to the surface window
-- that called this script. We can access the window
-- and its contents using it.

if SOURCE_NAME == "" then
	forms.error("must be called from surface or texture window only.")
	error()
end

function Process()
	t1 = MODULE.get_title1(SOURCE_NAME)
	t2 = MODULE.get_title2(SOURCE_NAME)
	fg = MODULE.get_matrix(SOURCE_NAME)

	m = CM.abs(fg)
	x,y = M.hist(m)

	wn = SOURCE_NAME .. "(HSTGRM)"
	window_manager.register(SOURCE_NAME, PROGRAM_NAME, wn)

	wn = chart(wn, FL_CHART_WINDOW)
	chart.clear(wn)
	chart.add(wn, x, y, t1, t2)
	chart.set_xlabel(wn, "Intensity")
	chart.set_ylabel(wn, "Relative Count")
	chart.update(wn)
end




