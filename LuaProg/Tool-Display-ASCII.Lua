L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

-- Get the currently selected line.
v, t, u = chart.get_vector(SOURCE_NAME)

NP, F0, F1, SR = chart.get_scan_parameters(SOURCE_NAME)
x = string.format("NPoints: %d  F0: %d  F1: %d  SR: %d\n", NP, F0, F1, SR)

f = V(#v, F0, chart.get_freq_step(SOURCE_NAME))

w = window_manager.make(FL_EDITOR_WINDOW, false)

window_manager.append_text(w, u .. "\n")
window_manager.append_text(w, t .. "\n")
window_manager.append_text(w, x)

for i = 1, #v do
	window_manager.append_text(w, 
		string.format("%4d\t%10.4f\t%10.4f\t%10.4f\n", i, f[i], v[i][1], v[i][2]) )
end

window_manager.set_changed(w, false)

