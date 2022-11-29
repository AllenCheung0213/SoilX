L = require("Util-Lua")

local params = {}
local PARAMS_FILE = "LuaProg/Tool-Batch-Config-Parameters.lua"

----------------------------------------------------------
----------------------------------------------------------
function edit_parameters()
	
	d = dialog("Batch Configuration Generator - v" .. VERSION, 600, 300, 180, 30)
	
	dialog.set_help(d, "Documentation/Batch Configuration Generator - Help File.doc");
	
	dialog.begin_tab(d, "File Settings")
	
	dialog.control(d, "INPUT", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Baseline Config File", FILE, "config_base", params.config_base)
	dialog.control(d, "Config Parameters File", FILE, "config_params", params.config_params)
	dialog.control(d, "OUTPUT", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Output Directory", DIR, "out_dir", params.out_dir)

	dialog.end_tab(d)
	
	dialog.begin_tab(d, "Advanced Settings")
	
	dialog.control(d, "POLARIZATION ALIAS PORT MAPPING", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Horizontal (H) Port", INTEGER, "hPortNum", params.hPortNum)
	dialog.control(d, "Vertival (V) Port", INTEGER, "vPortNum", params.vPortNum)
	dialog.control(d, "FORCE DATA MANAGEMENT SETTINGS", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Auto Save Data", CHECKBOX, "saveData", params.saveData)
	dialog.control(d, "Auto Increment Filename", CHECKBOX, "autoIncFile", params.autoIncFile)
	
	dialog.end_tab(d)
	
	params = dialog.show(d)
end

function define_default_params()
	local t = {
		config_base = "",
		config_params = "",
		out_dir = "",
		hPortNum = 1,
		vPortNum = 2,
		saveData = true,
		autoIncFile = true,
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