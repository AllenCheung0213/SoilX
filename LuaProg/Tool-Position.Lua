L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector
CM = complex_matrix
 M = matrix
 C = complex

pt = system.get_sweep_position_table()

v = CV()
ts = V()
for i,p in ipairs(pt) do
	CV.append(v, C(p.X, p.Y))
	V.append(ts, p.TIME_STAMP)
end

w = P(v, "Processed Position Data", data_source.get_filename())

--chart.set_property(w, SCATTER_LINE)
chart.set_xlabel(w, "Cross Range (m)")
chart.set_ylabel(w, "Range (m)")
chart.update(w)

t = V.shift(ts, 1) - ts
x = CV.abs(CV.shift(v, 1) - v) 
x[1] = 0

vel = -x / t

s = string.format("MIN = %.2f  MAX = %.2f  AVG = %.2f  STD = %.2f", V.stats(vel))
P(ts, -x / t, s, data_source.get_filename())
chart.set_xlabel(w, "Time (s)")
chart.set_ylabel(w, "Velocity (mps)")
chart.update(w)


