L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.Lua")

if SOURCE_NAME == "" then
	forms.error("Script (Tool-Convert-Marker-List.Lua) must be called from chart window only.")
end

do
	p = system.get_initial_position()
	print("initial_position", p) 

	function rescale_marker_table(v)
		for i = 1, table.maxn(v) do
			v[i].X = v[i].X - p[1]
			v[i].Y = v[i].Y - p[2]
		end
	end
end

v = chart.get_marker_table(SOURCE_NAME)
rescale_marker_table(v)
chart.set_marker_table(SOURCE_NAME, v)

v = chart.get_ground_truth_table(SOURCE_NAME)
rescale_marker_table(v)
chart.set_ground_truth_table(SOURCE_NAME, v)

chart.update(SOURCE_NAME)