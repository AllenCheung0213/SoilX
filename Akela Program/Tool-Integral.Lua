--
-- Tool-Derivative.Lua
--

L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.lua")

w = chart.spawn(SOURCE_NAME)
z = chart.size(w)

chart.clear(w)

for i = 1, z do
	v, t, u = chart.get_vector(SOURCE_NAME, i)
	if chart.is_analysis_window(SOURCE_NAME) then
		X = V(z, 0, 1); Y = v
	else
		X = CV.real(v); Y = CV.imag(v)
	end
	Y = V.cumsum(Y)
	chart.add(w, X, Y, t, u)
end

chart.set_autoscale(w, true)
chart.update(w)
