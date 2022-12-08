--
-- Startup.lua
--

function open_script_window(fn, execute)
	w = window_manager.make(FL_SCRIPT_WINDOW, true)
	window_manager.load_file(w, fn)
	if (execute) then
		window_manager.run(w)
	end
end

window_manager.make(FL_DATA_MANAGER_WINDOW, true)

-- A complete list of FL_ window types can be found in the APRD's help menu.

--window_manager.make(FL_CONFIG_HARDWARE, true)
--window_manager.make(FL_CONFIG_SYSTEM, true)
--window_manager.make(FL_CONFIG_FILTER, true)
--window_manager.make(FL_CONFIG_ACTIVATION, true)
--window_manager.make(FL_CONFIG_MENU, true)

--window_manager.make(FL_DATA_EDITOR_WINDOW, true)
--window_manager.make(FL_DASHBOARD_WINDOW, true)
--window_manager.make(FL_IMAGE_CONTROL_PANEL, true)


