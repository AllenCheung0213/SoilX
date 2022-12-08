plot = require("Util-plot")

----------------------------------------------------------
--Test script demonstrating the surface library...
----------------------------------------------------------

CV = complex_vector
 V = vector
CM = complex_matrix

---------------------------------------------
tape = data_tape.open()

NP, F0, F1, SR = data_tape.get_scan_parameters(tape)
print(NP, F0, F1, SR)


s = CM.avg(data_tape.get_matrix(tape))

--------
groupsize = 128

if groupsize > NP then
	forms.error( 
		string.format("Groupsize (%d) is greater than number of frequency points (%d).", 
			groupsize, #s))

	error()
end

v = V(groupsize, 1, 1) 

NFFT = 512

t = matrix(#s - groupsize, NFFT)
for k = 1, #s - groupsize do
	t[k] = CV.abs( CV.fft( s[v], NFFT, true) )
	v = v + 1
end

print(matrix.stats(t))

--plot("HIST", "HIST-01", matrix.hist(t, 64))

---------------------------------------------------------------------------------------
function Display(image, title)

	p = surface()

	surface.set(p, image, true)

	surface.set_xlabel(p, "SweepTime (ns)")
	surface.set_ylabel(p, "Frequency (MHz)")

	surface.set_title1(p, "Time-Frequency Distribution Analysis")
	surface.set_title2(p, title and title or "")

	dF = data_tape.get_freq_step(tape)
	dT = data_tape.get_time_step(tape, NFFT)

	f0 = F0 + dF * (groupsize / 2)
	f1 = F1 - dF * (groupsize / 2)

	t0 = 0
	t1 = dT * NFFT

	if tostring(dT) == "1.#INF" then 
		forms.message("error: invalid time step")
	else
		surface.set_scale(p, t0, t1, f0, f1)
	end

	surface.set_log_scale(p, true);

end

Display( t, data_tape.get_filename(tape) )
