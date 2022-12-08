--
-- ImageReconAnalysis.Lua
--

L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.Lua")

function Initialize(image_manager)
	print("Initialize", image_manager)

	cm = image.get_image_frame(image_manager)
	print(cm)
end

function Process(image_manager)
	print("Process", image_manager)

	cm = image.get_image_frame(image_manager)
	print(cm)

	m = CM.abs(cm)

	M.ipp_erode(m)
	M.ipp_erode(m)

--	M.ipp_dialate(m)
--	M.ipp_dialate(m)

	image.set_image_frame(image_manager, m)
end