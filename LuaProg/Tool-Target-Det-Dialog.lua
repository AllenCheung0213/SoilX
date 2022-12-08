L = require("Util-Lua")

local params = {}


----------------------------------------------------------
----------------------------------------------------------
function edit_parameters()
	
	d = dialog("Object Detection and Tracking", 540, 460, 300, 30)
	
	-- dialog.set_help(d, "Documentation/Data Processing Tools - Help.pdf");
	
	dialog.begin_tab(d, "Settings")
	
	dialog.control(d, "Read Data from File", CHECKBOX, "read_file", params.read_file)
	dialog.control(d, "Simulation Data File", FILE, "sim_data_file", params.sim_data_file)
	dialog.control(d, "SIMULATION SETTINGS", BOX, FL_NO_BOX)
	dialog.control(d, "No. FFT Points", INTEGER, "nFFT", params.nFFT)
	dialog.control(d, "Minimum Standoff Distance (m)", INTEGER, "min_d", params.min_d)
	dialog.control(d, "ANALYSIS PLOTTING", BOX, FL_NO_BOX)
	dialog.control(d, "Plot Range vs Scan", CHECKBOX, "range_plot", params.range_plot)
	dialog.control(d, "Plot Bearing Angle (BA) vs Scan", CHECKBOX, "bear_ang_plot", params.bear_ang_plot)
	dialog.control(d, "Plot BA Delta vs Collision Delta Threshold", CHECKBOX, "delta_plot", params.delta_plot)
	dialog.control(d, "Plot Object Tracking", CHECKBOX, "object_plot", params.object_plot)
	dialog.control(d, "Display Status Window", CHECKBOX, "status_win", params.status_win)
	dialog.control(d, "Real-time Analysis Playback", CHECKBOX, "realtime", params.realtime)
	
	dialog.end_tab(d)
	
	params = dialog.show(d)
end

function save_parameters()
	L.write_table("LuaProg/Tool-Target-Det-Parameters.lua", params)
end

function load_parameters()
	params = L.read_table("LuaProg/Tool-Target-Det-Parameters.lua")
end

function define_default_params()
	params = {
		read_file = false,
		sim_data_file = "",
		nFFT = 16384,
		min_d = 1000,
		range_plot = true,
		bear_ang_plot = true,
		delta_plot = true,
		object_plot = true,
		status_win = true,
		realtime = false,
	}
end

function get_parameters()
	
	params_file, err = io.open("LuaProg/Tool-Target-Det-Parameters.lua", "r")
	
	if err then
		define_default_params()
	else
		load_parameters()
	end
	
	edit_parameters()
	
	if (params ~= nil) then 
		save_parameters() 
	end

	return params
end