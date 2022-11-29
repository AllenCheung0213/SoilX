--
-- Tool-Data-Summary.lua
--
-- Generates a series of analysis windows -- one for each frame in the tape.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

 V = vector
DS = data_source
DT = data_tape


w = window_manager.make(FL_EDITOR_WINDOW, false)

if SOURCE_NAME == "" then
	tape = DS.get_tape()
	filename = DT.get_filename(tape)

	window_manager.append_text(w, filename .. "\n")

	for i = 1, #tape do
		window_manager.append_text(w, 
			"Line: " .. i - 1 .. "  " ..tape[i].FORMAT .. "\n")
	end
else
	title2 = chart.get_title2(SOURCE_NAME)

	window_manager.append_text(w, title2 .. "\n")

	sel = chart.get_selection_vector(SOURCE_NAME)

	for i = 1, chart.size(SOURCE_NAME) do
		if sel[i] == 1 then
			v, title1 = chart.get_vector(SOURCE_NAME, i)
			window_manager.append_text(w, 
					"Line: " .. i - 1 .. "  " .. title1 .. "\n")
		end
	end
end

window_manager.set_changed(w, false)


