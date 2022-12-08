L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

-- Get the currently selected line.
v, t, u = chart.get_vector(SOURCE_NAME)

w = window_manager.make(FL_EDITOR_WINDOW, false)

window_manager.append_text(w, u .. "\n")
window_manager.append_text(w, t .. "\n")

for i = 1, #v do
	window_manager.append_text(w, 
		string.format("%4d\t%10.4f\t%10.4f\n", i, v[i][1], v[i][2]) )
end

window_manager.set_changed(w, false)

