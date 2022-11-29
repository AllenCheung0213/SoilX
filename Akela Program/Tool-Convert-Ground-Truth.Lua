L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.Lua")

if SOURCE_NAME == "" then
	forms.error("Script (Tool-Convert-Marker-List.Lua) must be called from chart window only.")
end

marker_vector = chart.get_ground_truth_vector(SOURCE_NAME)

marker_vector = marker_vector[V.sort_indexed(CV.real(marker_vector))]

chart.add(SOURCE_NAME, marker_vector, 
	"Marker List", 
	string.format("%d Points", #marker_vector) )

chart.update(SOURCE_NAME)