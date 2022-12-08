
L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

v = {}
t = {}
u = {}

print("SOURCE_NAME", SOURCE_NAME)

v1, t1, u1 = chart.get_vector(SOURCE_NAME, 1)
v2, t2, u2 = chart.get_vector(SOURCE_NAME, 2)

if chart.is_analysis_window(SOURCE_NAME) then
	v3 = v2 - v1
else
	v3 = CV(CV.real(v1), CV.imag(v2) - CV.imag(v1))
end

w = chart.spawn(SOURCE_NAME)
print(w, chart.size(w))
chart.clear(w)
chart.add(w, v1, t1, u1)
chart.add(w, v2, t2, u2)
chart.add(w, v3, "Difference")
chart.update(w)
