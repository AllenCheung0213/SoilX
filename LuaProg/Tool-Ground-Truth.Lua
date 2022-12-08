L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector
CM = complex_matrix
 M = matrix
 C = complex

AP = config.get_analysis_parameter_table()

filename = AP.GROUND_TRUTH_PATH
if file.is_file(filename) == false then
	forms.error(string.format("Unable to open file: %s\nSee Image Control Panel | Ground", filename))
end
GT = config.get_ground_truth_table(filename)

gt = CV()
for k,v in pairs(GT) do
	x = v.EASTING
	y = v.NORTHING
	CV.append(gt, C(x, y))
end 

w = window_manager.make(FL_EDITOR_WINDOW, false)

window_manager.append_text(w, filename .. "\n")

P0 = system.get_initial_position()

window_manager.append_text(w, string.format(
	"inital position = %12.4f %12.4f\n", P0[1], P0[2] ))

for i = 1, #GT do
	window_manager.append_text(w, 
		string.format("%10s  %12.4f  %12.4f  %12.4f  %12.4f\n", GT[i].LABEL, 
				gt[i][1] - P0[1], 
				gt[i][2] - P0[2], 
				gt[i][1], 
				gt[i][2]) )
end

window_manager.set_changed(w, false)

p = P(gt)
chart.set_property(p, SCATTER)
chart.set_xlabel(p, "Easting (m)")
chart.set_ylabel(p, "Northing (m)")
chart.update(p)
