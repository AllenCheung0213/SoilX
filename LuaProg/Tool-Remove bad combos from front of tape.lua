L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.Lua")

fn = forms.get_filename("Open Tape", "Text Files(*.imb)\tAll Files(*.*)", 
		system.get_working_data_dir())

if fn == "" then error() end

old_tape = data_tape.read(fn)

new_tape = data_tape()
data_tape.copy_header(new_tape, old_tape)

save = false
for i = 1, #old_tape do
	if old_tape[i].FRAME_NUMBER == 1 then save = true end
	if save then data_tape.append(new_tape, old_tape[i]) end
end

data_tape.write(new_tape, fn)

data_source.set_tape(new_tape)

