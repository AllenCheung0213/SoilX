--
-- Tool-K-THETA-Parameters.Lua
--

Lua = require("UTIL-Lua")

---------------------------------------------
---------------------------------------------
function edit_parameters(params)

	function verify(t)
		print("HERE - verify")
		return true
	end	

	--First thing to do is make a dialog specifying window title, width,
	--height, left margin and right margin.  All parameters are
	--optional.
	local d = dialog("Generate Nulling/Background File", 600, 280, 140, 50)

	--Note that the path can be specified relative to the
	--current working directory.
	--dialog.set_help(d, "HTMLHelp/Demo-Dialog.html");

	--Add tabs to the dialog using begin_ and end_tab functions.
	dialog.begin_tab(d, "Options")

	dialog.control(d, "Use Current Data", CHECKBOX, "use_memory", params.use_memory)
	dialog.control(d, "N-Frames Warmup", INTEGER, "nframe_warmup", params.nframe_warmup)
	dialog.control(d, "N-Frames Keep", INTEGER, "nframe_retain", params.nframe_retain)
	dialog.control(d, "Remove Stitch Point", CHECKBOX, "remove_stitch", params.remove_stitch)
	dialog.control(d, "Use Simple Average", CHECKBOX, "use_average", params.use_average)
--	dialog.control(d, "Warmup Time (s)", NUMBER, "warmup_time", params.warmup_time)

	--End this tab.
	dialog.end_tab(d)

	--When done adding tabs and controls, show the dialog. This
	--does, internally, a few other things as well (see verify).
	--Show returns a table.
	return dialog.show(d)
end

---------------------------------------------
---------------------------------------------
function get_parameters()

	local filename = "LuaProg/K-THETA-Parameters.lua"

	file, err = io.open(filename, "r")
	if err then
		params = {
			use_memory = false,
			nframe_warmup = 0,
			nframe_retain = 128,
			remove_stitch = true,
			warmup_time = 0,
			use_average = false
		}
	else
		params = Lua.read_table(filename)
	end

	params = edit_parameters(params)
	if params == nil then
		error("user canceled operation")
	else
		Lua.write_table(filename, params)
	end

	return params
end

