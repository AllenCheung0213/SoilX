L = require("Util-Lua")
plot = require("Util-plot")

local params = {}
local PARAMS_FILE = "LuaProg/Tool-Noise-Parameters.lua"
----------------------------------------------------------
----------------------------------------------------------
function edit_parameters()

	d = dialog("Noise Analysis", 500, 355, 220, 30 )

	dialog.begin_tab(d, "Settings")

	--dialog.control(d, "Use Saved Data File", CHECKBOX, "use_file", false)
	--dialog.control(d, "Saved Data File", FILE, "data_file", "")
	dialog.control(d, "TX No.", INTEGER, "tx", params.tx)
	dialog.control(d, "RX No.", INTEGER, "rx", params.rx)
 	dialog.control(d, "Analysis Starting Scan No.", INTEGER, "scan_start", params.scan_start)
 	dialog.control(d, "Limit No. of Scans", CHECKBOX, "limit_scans", params.limit_scans)
 	dialog.control(d, "Max No. of Scans", INTEGER, "scan_num", params.scan_num)
	dialog.control(d, "StdDev Group Size", INTEGER, "scan_win", params.scan_win)
	dialog.control(d, "Windowing", CHECKBOX, "windowing", params.windowing)

	dialog.end_tab(d)

	dialog.begin_tab(d, "Analyses")

	dialog.control(d, "Frequency Domain", CHECKBOX, "freq_dom", params.freq_dom)
	dialog.control(d, "Time Domain", CHECKBOX, "time_dom", params.time_dom)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Magnitude(StdDev)", CHECKBOX, "mag_sd", params.mag_sd)
	dialog.control(d, "StdDev(Magnitude)", CHECKBOX, "sd_mag", params.sd_mag)
	dialog.control(d, "StdDev(Phase)", CHECKBOX, "sd_phase", params.sd_phase)
	dialog.control(d, "StdDev(i)", CHECKBOX, "sd_i", params.sd_i)
	dialog.control(d, "StdDev(q)", CHECKBOX, "sd_q", params.sd_q)

	dialog.end_tab(d)

	dialog.begin_tab(d, "Plots")

	dialog.control(d, "Scalar Plot", CHECKBOX, "plot_scalar", params.plot_scalar)
	dialog.control(d, "Image", CHECKBOX, "plot_image", params.plot_image)
	dialog.control(d, "Histogram", CHECKBOX, "plot_hist", params.plot_hist)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Plot Time Domain in Log Scale", CHECKBOX, "log_scale", params.log_scale)
	
	dialog.end_tab(d)
	
	dialog.begin_tab(d, "File Output")

	dialog.control(d, "Output to File(s)", CHECKBOX, "file_out", params.file_out)
	dialog.control(d, "Output Directory", DIR, "file_dir", params.file_dir)
	
	dialog.end_tab(d)
	
	
	params = dialog.show(d)
end


function define_default_params()
	local t = {
	  limit_scans = false,
	  scan_num = 0,
	  windowing = true,
	  time_dom = false,
	  scan_win = 10,
	  plot_scalar = true,
	  sd_mag = false,
	  scan_start = 1,
	  plot_hist = false,
	  sd_phase = false,
	  sd_q = false,
	  tx = 1,
	  mag_sd = true,
	  rx = 2,
	  log_scale = false,
	  file_out = false,
	  sd_i = false,
	  plot_image = false,
	  freq_dom = true,
	  file_dir = "ScratchData",
	}
	return t
end

----------------------------------------------------------
-- Write Values from Dialog Parameter Values
----------------------------------------------------------

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





