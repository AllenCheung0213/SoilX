L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.Lua")

if SOURCE_NAME == "" then
	forms.set_working_dir(system.get_working_analysis_dir())
	filename = forms.get_filename("Open Marker File", "Marker Files(*.txt)\tAll Files(*.*)")
	marker_list = file.read_marker_vector(filename)
else
	window_type = window_manager.get_window_type(SOURCE_NAME)
	if window_type == FL_CHART_WINDOW then
		marker_list = chart.get_marker_vector(SOURCE_NAME)
	elseif window_type == FL_IMAGE_MONITOR_WINDOW or window_type == FL_2D_WINDOW then
		marker_list = surface.get_marker_vector(SOURCE_NAME)
	end
	filename = SOURCE_NAME
end

L.display(marker_list)

position_table = system.get_sweep_position_table()

do 
	initial_position = system.get_initial_position()

	function make_world(Pc, Ps)
		return initial_position + C(Ps.X, Ps.Y) + C.rotate(Pc, -Ps.THETA)
	end

	function make_relative(Pw, Ps)
		return C.rotate(Pw - C(Ps.X, Ps.Y) - initial_position, Ps.THETA)
	end
end

do
	local slice = config.get_analysis_parameter_table().XY
	function is_inside_slice(Pc)
		if Pc[1] < slice.W0 then return false end
		if Pc[1] > slice.W1 then return false end
		if Pc[2] < slice.H0 then return false end
		if Pc[2] > slice.H1 then return false end
		return true
	end
end


function get_sweep_number_list(marker)
	sweep_number_list = V()
	for j = 1, #position_table do
		position = position_table[j]
		Pc = make_relative(marker, position)
		if is_inside_slice(Pc) then
			V.append(sweep_number_list, position.SWEEP_NUMBER)
		end
	end
	return sweep_number_list
end

w = window_manager.make(FL_TEXT_WINDOW, "Sweep vs Marker Number")

d = { file.get_name(filename), "---------------------------" }
for i = 1, #marker_list do
	sweep_number_list = get_sweep_number_list(marker_list[i])
	table.insert(d, string.format("Marker %d Sweep %d", i, V.avg(sweep_number_list) ))
end

window_manager.update(w, d)







