--
-- Implements a 1st Order Motion Algorithm on raw data.
--

L = require("Util-Lua")

d = forms.get_working_dir()
x = file.get_directory_structure(d, true)

function convert_file(dst, src)

	print("Converting", src)

	tape = data_tape.read(src)

	data_tape.write(tape, dst)
	
end

if d ~= nil then
	for k in pairs(x) do
		src = x[k].ABSOLUTE
		if string.lower(file.get_ext(src)) == ".img" then
			dst = file.set_ext(src, ".imb")
			convert_file(dst, src)
		end
	end
end
