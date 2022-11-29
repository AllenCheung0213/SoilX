--
-- Tool-Spectrum-Display.Lua
--

L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

--The data source contains a single tape.
tape = data_source.get_tape()

if #tape == 0 then
	error("*** EMPTY TAPE ***")
end

--Going to need the scan parameters for the analysis window.
ND, F0, F1, SR = data_tape.get_scan_parameters(tape)

--Make a title using the current center frequency.
U = string.format("Scan Rate: %d  Center Frequency: %g", SR, F0)

w = chart(FL_ANALYSIS_WINDOW)

--Need to calculate effective scan parameters so the
--analysis window will behave properly.
F0 = -SR / 2 / 1e6
F1 =  SR / 2 / 1e6

chart.set_scan_parameters(w, ND, F0, F1, SR)

for i = 1, #tape do

	local S = tape[i];

	--Convert to the frequency domain.
	F = CV.fft(S.DATA, 1024, true)

	--Shift the data so it is aligned on zero frequency.
	F = CV.shift(F, #F / 2)

	--Get default description of this scan.
	T = S.FORMAT

	chart.add(w, F, T, U)
	chart.update(w)

end




