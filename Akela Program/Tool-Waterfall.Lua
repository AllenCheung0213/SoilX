plot = require("Util-plot")

CV = complex_vector
 V = vector

CM = complex_matrix
 M = matrix

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
	local d = dialog("Waterfall Parmeters", 500, 420, 140, 50)

	--Note that the path can be specified relative to the
	--current working directory.
	--dialog.set_help(d, "HTMLHelp/Demo-Dialog.html");

	--Add tabs to the dialog using begin_ and end_tab functions.
	dialog.begin_tab(d, "Waterfall")

	dialog.control(d, "Use Filename", CHECKBOX, "use_filename", params.use_filename)
	dialog.control(d, "Filename", FILE, "filename", params.filename)
	dialog.control(d, "TX", NUMBER, "TX", params.TX)
	dialog.control(d, "RX", NUMBER, "RX", params.RX)
	dialog.control(d, "First Frame", NUMBER, "F0", params.F0)
	dialog.control(d, "Last Frame", NUMBER, "F1", params.F1)
	dialog.control(d, "Depth", NUMBER, "depth", params.depth)
	dialog.control(d, "No FFT Points", NUMBER, "nFFT", params.nFFT)
	dialog.control(d, "Cable Delays", CHECKBOX, "use_cable_delays", params.use_cable_delays)
	dialog.control(d, "Log Scale", CHECKBOX, "use_log_scale", params.use_log_scale)

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

	local filename = "waterfall-parameters.lua"

	file, err = io.open(filename, "r")
	if err then
		params = {
			use_filename = false,
			filename = "",
			TX = 0,
			RX = 0,
			F0 = 1,
			F1 = 9999,
			depth = 9999,
			nFFT = 4096,
			use_cable_delays = true,
			use_log_scale = true
		}
	else
		params = L.read_table(filename)
	end

	params = edit_parameters(params)
	if params == nil then
		error("user canceled operation")
	else
		L.write_table(filename, params)
	end

	return params
end

parameters = get_parameters()

---------------------------------------------
---------------------------------------------
if parameters.use_filename then
	tape = data_tape.read(parameters.filename)
	data_source.set_tape(tape)
else
	tape = data_source.get_tape()
end

---------------------------------------------
SL = config.get_sensor_table()

NF, F0, F1, SR = data_tape.get_scan_parameters(tape)
print("NF, F0, F1, SR", NF, F0, F1, SR)

NS = #tape

step = data_tape.get_freq_step(tape, NF, F0, F1)
freqs = vector(NF, F0, step)

print("NFreq, NScan = ", NF, NS)

---------------------------------------------
function is_valid_scan(S)
	return S.TX == parameters.TX + 1 and 
		   S.RX == parameters.RX + 1 and
		   S.FRAME_NUMBER >= parameters.F0 and
		   S.FRAME_NUMBER <= parameters.F1
end
---------------------------------------------
tape = tape[is_valid_scan]

---------------------------------------------
---------------------------------------------
T = data_tape.get_matrix(tape)

A = CM.fft(T, parameters.nFFT, F0, F1, true)

if parameters.use_log_scale then
	A = CM.dec(A)
else
	A = CM.abs(A)
end

dT = data_tape.get_time_step(tape, parameters.nFFT)
N = parameters.depth / 0.15 / dT

A = M.truncate2(A, N)
A = M.reverse(A)
A = M.transpose(A) 

---------------------------------------------

tx_delay = SL[parameters.TX + 1].TX_DELAY
rx_delay = SL[parameters.RX + 1].RX_DELAY

if parameters.use_cable_delays then
	total_delay = tx_delay + rx_delay
	distance_correction = -0.15 * total_delay
else
	distance_correction = 0.0
end

print(total_delay, distance_correction)
---------------------------------------------
X0 = 0
X1 = tape[#tape].TIMESTAMP

Y0 = 0.15 * #A * dT + distance_correction
Y1 = distance_correction

---------------------------------------------
---------------------------------------------
p = surface("Waterfall-01")
surface.set(p, A)
surface.set_scale(p, X0, X1, Y0, Y1)
surface.set_title1(p, "Depth vs Scan Time")
surface.set_title2(p, parameters.filename)
surface.set_xlabel(p, "Time (s)")
surface.set_ylabel(p, "Depth (m)")
surface.update(p)



 