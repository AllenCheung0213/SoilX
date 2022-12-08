--
-- Z Image Slices.Lua
--

Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

dofile("LuaProg/UTIL-Header.lua")


AP = config.get_analysis_parameter_table()
Lua.display(AP)

window_name = "Z Image Slices"

function initialize_plot_matrix(m, t1, t2, n)

	local s = texture(window_name)
	texture.clear(s)
end

function plot_matrix(m, t1, t2, n)
	local s = texture(window_name)
	texture.set_title1(s, t1)
	texture.set_title2(s, t2)
	texture.set(s, CM.abs(m), t1, t2)
	texture.set_xlabel(s, "Cross Range (m)")
	texture.set_ylabel(s, "Range (m)")
	texture.set_scale(s, -4, 4, 17, 23)
	texture.update(s)
end

filename = DS.get_filename()
frame_number = 17
sweep_number = 130

img = image()

tape = DS.get_tape()
if #tape == 0 then
	forms.error("Data tape found empty.")
end

initialize_plot_matrix()

for z = 0.0, 1.0, 0.2 do

	AP.XY.D0 = -z
--	config0.set_analysis_parameter_table(AP)

	image.initialize(img, AP)

	idx = DT.get_sweep(tape, sweep_number)
	mat = image.get_image(img, tape[idx])

	plot_matrix(mat, filename, "z = " .. tostring(z) .. " meter", frame_number)

	print("z = " .. tostring(z) .. " meter", frame_number)

end

