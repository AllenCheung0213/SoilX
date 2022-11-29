L = require("UTIL-Lua")
P = require("UTIL-Plot")

src = data_source.get_tape()
dst = data_tape()

data_tape.copy_header(dst, src)

for i = 1, #src do
	data_tape.append(dst, data_scan.set_GPS_state(src[i], true))
end

data_source.set_tape(dst)
