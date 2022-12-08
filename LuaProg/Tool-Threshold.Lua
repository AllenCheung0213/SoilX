L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

CM = complex_matrix
 M = matrix

-- SOURCE_NAME is bound to the surface window
-- that called this script. We can access the window
-- and its contents using it.

if SOURCE_NAME == "" then
	forms.error("Must be called from surface window only.")
	error()
end

function Process()
t1 = MODULE.get_title1(SOURCE_NAME)
t2 = MODULE.get_title2(SOURCE_NAME)
fg = MODULE.get_matrix(SOURCE_NAME)

m = CM.abs(fg)

if true then
	MIN, MAX, AVG, STD = M.stats(m)

	if AVG > 0 then 
		TAU = AVG --+ (MAX - AVG) / 2
		TAU = (TAU - MIN) / (MAX - MIN) * 255
		MODULE.set_min_color(SOURCE_NAME, TAU)
	end
else
	TAU = M.THRJOH(m)
	MODULE.set_min_color(SOURCE_NAME, TAU)
end

print("TAU = ", TAU)

x,y = M.hist(m)

w = chart(SOURCE_NAME .. "(THRHLD)", FL_CHART_WINDOW)
window_manager.register(SOURCE_NAME, PROGRAM_NAME, w)

chart.clear(w)
chart.add(w, x, y, t1, t2)

chart.set_xlabel(w, "Intensity")
chart.set_ylabel(w, "Pixel Count")

chart.update(w)
end
