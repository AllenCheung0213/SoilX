L = require("Util-Lua")

local params = {}
local PARAMS_FILE = "LuaProg/Tool-Simulate-Data-Gen-Parameters.lua"


----------------------------------------------------------
----------------------------------------------------------
function edit_parameters()
	
	d = dialog("Simulation Data Generation - v" .. VERSION, 500, 720, 220, 30)
	
	-- dialog.set_help(d, "Documentation/Data Processing Tools - Help.pdf");
	
	dialog.begin_tab(d, "System Settings")
	
	dialog.control(d, "System in Motion", CHECKBOX, "sen_mov", params.sen_mov)
	dialog.control(d, "System Velocity (m/s)", NUMBER, "sen_vel", params.sen_vel)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "sen_ang", params.sen_ang)
	dialog.control(d, "SYSTEM PARAMETERS", BOX, FL_NO_BOX)
	dialog.control(d, "Power of R", NUMBER, "pow_r", params.pow_r)
	dialog.control(d, "Tx Power (dBm)", NUMBER, "tx_pow", params.tx_pow)
	dialog.control(d, "Rx FS Power (dBm)", NUMBER, "rx_fs_pow", params.rx_fs_pow)
	dialog.control(d, "Tx Antenna Gain (dBi)", NUMBER, "tx_gain", params.tx_gain)
	dialog.control(d, "Rx Antenna Gain (dBi)", NUMBER, "rx_gain", params.rx_gain)
	dialog.control(d, "Radar Loss Factor (scale)", NUMBER, "loss_factor", params.loss_factor)
	dialog.control(d, "SIGNAL NOISE", BOX, FL_NO_BOX)
	dialog.control(d, "Add System Noise", CHECKBOX, "noise", params.noise)
	dialog.control(d, "Noise Background File", FILE, "noise_filename", params.noise_filename)
	dialog.control(d, "SIMULATION SETTINGS", BOX, FL_NO_BOX)
	dialog.control(d, "Simulation Duration (sec)", NUMBER, "sim_time", params.sim_time)
	dialog.control(d, "FILE OUTPUT", BOX, FL_NO_BOX)
	dialog.control(d, "Output to File", CHECKBOX, "out_file", params.out_file)
	dialog.control(d, "Output Filename", FILE, "out_filename", params.out_filename)	

	dialog.end_tab(d)
	
	dialog.begin_tab(d, "Moving Objects")
	
	dialog.control(d, "Moving Object 1", CHECKBOX, "obj1", params.obj1)
	dialog.control(d, "Initial X Position (m)", NUMBER, "obj1_x", params.obj1_x)
	dialog.control(d, "Initial Y Position (m)", NUMBER, "obj1_y", params.obj1_y)
	dialog.control(d, "Object Velocity (m/s)", NUMBER, "obj1_vel", params.obj1_vel)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "obj1_ang", params.obj1_ang)
	dialog.control(d, "RCS (m^2)", NUMBER, "obj1_rcs", params.obj1_rcs)
	dialog.control(d, "Moving Object 2", CHECKBOX, "obj2", params.obj2)
	dialog.control(d, "Initial X Position (m)", NUMBER, "obj2_x", params.obj2_x)
	dialog.control(d, "Initial Y Position (m)", NUMBER, "obj2_y", params.obj2_y)
	dialog.control(d, "Object Velocity (m/s)", NUMBER, "obj2_vel", params.obj2_vel)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "obj2_ang", params.obj2_ang)
	dialog.control(d, "RCS (m^2)", NUMBER, "obj2_rcs", params.obj2_rcs)
	dialog.control(d, "Moving Object 3", CHECKBOX, "obj3", params.obj3)
	dialog.control(d, "Initial X Position (m)", NUMBER, "obj3_x", params.obj3_x)
	dialog.control(d, "Initial Y Position (m)", NUMBER, "obj3_y", params.obj3_y)
	dialog.control(d, "Object Velocity (m/s)", NUMBER, "obj3_vel", params.obj3_vel)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "obj3_ang", params.obj3_ang)
	dialog.control(d, "RCS (m^2)", NUMBER, "obj3_rcs", params.obj3_rcs)
	
	dialog.end_tab(d)
	
	dialog.begin_tab(d, "Breathing Objects")
	
	dialog.control(d, "Breathing Object 1", CHECKBOX, "obj_breath1", params.obj_breath1)
	dialog.control(d, "Initial X Position (m)", NUMBER, "obj_breath1_x", params.obj_breath1_x)
	dialog.control(d, "Initial Y Position (m)", NUMBER, "obj_breath1_y", params.obj_breath1_y)
	dialog.control(d, "Breathing Motion Rate (cyc/m)", NUMBER, "obj_breath1_rate", params.obj_breath1_rate)
	dialog.control(d, "Breathing Motion Size (in)", NUMBER, "obj_breath1_throw", params.obj_breath1_throw)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "obj_breath1_ang", params.obj_breath1_ang)
	dialog.control(d, "RCS (m^2)", NUMBER, "obj_breath1_rcs", params.obj_breath1_rcs)
	dialog.control(d, "Breathing Object 2", CHECKBOX, "obj_breath2", params.obj_breath2)
	dialog.control(d, "Initial X Position (m)", NUMBER, "obj_breath2_x", params.obj_breath2_x)
	dialog.control(d, "Initial Y Position (m)", NUMBER, "obj_breath2_y", params.obj_breath2_y)
	dialog.control(d, "Breathing Motion Rate (cyc/m)", NUMBER, "obj_breath2_rate", params.obj_breath2_rate)
	dialog.control(d, "Breathing Motion Size (in)", NUMBER, "obj_breath2_throw", params.obj_breath2_throw)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "obj_breath2_ang", params.obj_breath2_ang)
	dialog.control(d, "RCS (m^2)", NUMBER, "obj_breath2_rcs", params.obj_breath2_rcs)
	dialog.control(d, "Breathing Object 3", CHECKBOX, "obj_breath3", params.obj_breath3)
	dialog.control(d, "Initial X Position (m)", NUMBER, "obj_breath3_x", params.obj_breath3_x)
	dialog.control(d, "Initial Y Position (m)", NUMBER, "obj_breath3_y", params.obj_breath3_y)
	dialog.control(d, "Breathing Motion Rate (cyc/m)", NUMBER, "obj_breath3_rate", params.obj_breath3_rate)
	dialog.control(d, "Breathing Motion Size (in)", NUMBER, "obj_breath3_throw", params.obj_breath3_throw)
	dialog.control(d, "Angle of Motion (deg)", NUMBER, "obj_breath3_ang", params.obj_breath3_ang)
	dialog.control(d, "RCS (m^2)", NUMBER, "obj_breath3_rcs", params.obj_breath3_rcs)
	
	dialog.end_tab(d)
	
	-- dialog.begin_tab(d, "Stationary Objects")
	
	-- dialog.control(d, "Stationary Object 1", CHECKBOX, "obj_static1", params.obj_static1)
	-- dialog.control(d, "Initial X1 Position (m)", NUMBER, "obj_static1_x1", params.obj_static1_x1)
	-- dialog.control(d, "Initial Y1 Position (m)", NUMBER, "obj_static1_y1", params.obj_static1_y1)
	-- dialog.control(d, "Initial X2 Position (m)", NUMBER, "obj_static1_x2", params.obj_static1_x2)
	-- dialog.control(d, "Initial Y2 Position (m)", NUMBER, "obj_static1_y2", params.obj_static1_y2)
	-- dialog.control(d, "RCS (m^2)", NUMBER, "obj_static1_rcs", params.obj_static1_rcs)
	
	dialog.end_tab(d)
	
	params = dialog.show(d)
end

function define_default_params()
	local t = {
		sen_mov = false,
		sen_vel = 5,
		sen_ang = 0,
		pow_r = 4.0,
		-- pow_rcs = 1.0,
		tx_pow = 18.0,
		rx_fs_pow = -43.0,
		tx_gain = 2.2,
		rx_gain = 2.2,
		loss_factor = 0.79,
		noise = false,
		noise_filename = "",
		out_file = false,
		out_filename = "",
		sim_time = 20,
		obj1 = true,
		obj1_x = 0,
		obj1_y = 10,
		obj1_vel = 1,
		obj1_ang = 0,
		obj1_rcs = 1,
		obj2 = false,
		obj2_x = 0,
		obj2_y = 20,
		obj2_vel = 1,
		obj2_ang = 0,
		obj2_rcs = 1,
		obj3 = false,
		obj3_x = 0,
		obj3_y = 30,
		obj3_vel = 1,
		obj3_ang = 0,
		obj3_rcs = 1,
		obj_breath1 = false,
		obj_breath1_x = 0,
		obj_breath1_y = 10,
		obj_breath1_rate = 16,
		obj_breath1_throw = 1,
		obj_breath1_ang = 0,
		obj_breath1_rcs = 1,
		obj_breath2 = false,
		obj_breath2_x = 0,
		obj_breath2_y = 20,
		obj_breath2_rate = 16,
		obj_breath2_throw = 1,
		obj_breath2_ang = 0,
		obj_breath2_rcs = 1,
		obj_breath3 = false,
		obj_breath3_x = 0,
		obj_breath3_y = 30,
		obj_breath3_rate = 16,
		obj_breath3_throw = 1,
		obj_breath3_ang = 0,
		obj_breath3_rcs = 1,
		-- obj_static1 = false,
		-- obj_static1_x1 = 0,
		-- obj_static1_y1 = 0,
		-- obj_static1_x2 = 0,
		-- obj_static1_y2 = 0,
		-- obj_static1_rcs = 1,
	}
	return t
end

function corr_params(p)
	-- If the loaded parameters don't contain all of the parameters specified by default
	-- then the additional parameters will be added
	for k in pairs(p) do
		if (params[k] == nil) then
			params[k] = p[k]
		end
	end
	
	-- If the loaded parameters contain parameters that aren't specified by default
	-- then the additional parameters will be removed
	for k in pairs(params) do
		if (p[k] == nil) then
			params[k] = nil
		end
	end
end

function get_parameters()
	
	file_handle, err = io.open(PARAMS_FILE, "r")
	
	if err then
		params = define_default_params()
	else
		temp_params = define_default_params()
		params = L.read_table(PARAMS_FILE)
		corr_params(temp_params)
	end
	
	edit_parameters()
	
	if (params ~= nil) then 
		L.write_table(PARAMS_FILE, params)
	else
		error("User canceled operation")
	end

	return params
end