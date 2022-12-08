--
-- Tool-Group-Delay-Parameters.Lua
--

Lua = require("UTIL-Lua")

---------------------------------------------
---------------------------------------------
function show_parameter_dialog(params)

	function verify(t)
		print("HERE - verify")
		return true
	end	

	--First thing to do is make a dialog specifying window title, width,
	--height, left margin and right margin.  All parameters are
	--optional.
	local d = dialog("Generate Group Delay File", 650, 470, 190, 50)

	--Note that the path can be specified relative to the
	--current working directory.
	--dialog.set_help(d, "HTMLHelp/Demo-Dialog.html");

	--Add tabs to the dialog using begin_ and end_tab functions.
	dialog.begin_tab(d, "Options")
		dialog.control(d, "Output Calibration Path", FILE, "output_filename", params.output_filename, ".cal")
		dialog.control(d, "-----------------", BOX, FL_NO_BOX)
		dialog.control(d, "Use Data File", CHECKBOX, "use_data_file", params.use_data_file)
		dialog.control(d, "Source Data Path", FILE, "data_filename", params.data_filename)
		dialog.control(d, "-----------------", BOX, FL_NO_BOX)
		dialog.control(d, "Use Reference Antenna", CHECKBOX, "use_reference_antenna", params.use_reference_antenna)
		dialog.control(d, "Reference Calibration Path", FILE, "reference_filename", params.reference_filename)
		dialog.control(d, "-----------------", BOX, FL_NO_BOX)
		dialog.control(d, "Antenna Separation (m)", NUMBER, "antenna_separation", params.antenna_separation)
		dialog.control(d, "Internal Delay (ns)", NUMBER, "internal_delay", params.internal_delay)
		dialog.control(d, "TX Delay (ns)", NUMBER, "TX_delay", params.TX_delay)
		dialog.control(d, "RX Delay (ns)", NUMBER, "RX_delay", params.RX_delay)
	dialog.end_tab(d)

	--When done adding tabs and controls, show the dialog. This
	--does, internally, a few other things as well (see verify).
	--Show returns a table.
	return dialog.show(d)
end

---------------------------------------------
---------------------------------------------
function get_parameter_table()

	local filename = "Group-Delay-Parameters.lua"

print(filename)

	_file, err = io.open(filename, "r")
	if err then
		params = {
			output_filename = "",
			use_data_file = false,
			data_filename = "",
			use_reference_antenna = false,
			reference_filename = "",
			antenna_separation = 0,
			internal_delay = 0,
			TX_delay = 0,
			RX_delay = 0
		}
	else
		params = Lua.read_table(filename)
	end

	return params
end

---------------------------------------------
---------------------------------------------
function edit_parameter_table()

	local filename = "Group-Delay-Parameters.lua"

	params = show_parameter_dialog(get_parameter_table())
	if params ~= nil then
		Lua.write_table(filename, params)
	end

	return params
end
-- For testing purposes only!
--params = edit_parameter_table()
