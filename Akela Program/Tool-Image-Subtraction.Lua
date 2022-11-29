L = require("UTIL-Lua")
P = require("UTIL-Plot")

if SOURCE_NAME == "" then
	forms.error("must be called from surface window only.")
	error()
end

t1 = surface.get_title1(SOURCE_NAME)
t2 = surface.get_title2(SOURCE_NAME)


function plot_matrix(m, t1, t2, n)
	local s = surface(SOURCE_NAME .. tostring(n))
	surface.set_title1(s, t1)
	surface.set_title2(s, t2)
	surface.set(s, m)
	surface.set_xlabel(s, "Cross Range (m)")
	surface.set_ylabel(s, "Range (m)")
	surface.set_scale(s, -6, 6, 4, 8)
	surface.update(s)
end

bg = file.read_complex_matrix("Set1_1_90.txt")
fg = surface.get_matrix(SOURCE_NAME)

m = fg - bg

roi = image.get_roi(m, 260, 370, 55, 85)
min, max, avg = matrix.stats(complex_matrix.abs(roi))

t2 = string.format("Avg Magnitude = %.3f", avg)
plot_matrix(m, t1, t2)
