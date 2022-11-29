---------------------------------------------------------------------------------------
plot = require("UTIL-Plot")
L = require("UTIL-Lua")

---------------------------------------------------------------------------------------
CM = complex_matrix
CV = complex_vector
 C = complex
 V = vector

-- Get the file.
---------------------------------------------------------------------------------------
tape = data_tape.open()
if (tape == nil) then error() end

NP, F0, F1, SR = data_tape.get_scan_parameters(tape)
print(NP, F0, F1, SR)

NFFT = 512

---------------------------------------------------------------------------------------
function Display(image, title)

	p = surface()

	surface.set(p, CM.abs(image), true)

	surface.set_title1(p, "Range Profile")
	surface.set_title2(p, title and title or "")


	surface.set_xlabel(p, "Sweep Time(ns)")
	surface.set_ylabel(p, "Scan Number")

	dT = data_tape.get_time_step(tape, NFFT)

	t0 = 0
	t1 = dT * NFFT

	surface.set_scale(p, t0, t1, 0, #tape)

	surface.set_log_scale(p, true);

end

---------------------------------------------------------------------------------------
m = data_tape.get_matrix(tape)

f = CM.fft(m, NFFT, true)

Display(f, data_tape.get_filename(tape) )

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
