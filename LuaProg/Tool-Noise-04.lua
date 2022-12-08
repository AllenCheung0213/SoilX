plot = require("Util-plot")

----------------------------------------------------------
--Test script demonstrating the surface library...
----------------------------------------------------------

CV = complex_vector
 V = vector

CM = complex_matrix
 M = matrix

-- The tape represents a complex matrix. Each
-- row is a scan represnted by a complex_vector
tape = data_source.get_tape()

if #tape == 0 then
	error("empty tape")
end

-- GET no-data-points, start- and stop-frequency,
-- and scan-rate which will be converted to
-- a time-step.
ND, F0, F1, SR = data_tape.get_scan_parameters(tape)
print(ND, F0, F1, SR)

-- no of scans
NS = #tape

-- no of frequencies
NF = ND

step = data_tape.get_freq_step(tape, ND, F0, F1)
freqs = V(NF, F0, step)

print("ND, NS = ", ND, NS)

---------------------------------------------
---------------------------------------------
-- Need to drag out all the scans so the matrix can be inverted.
T = CM(NS, NF)

for i = 1, NS do
	T[i] = tape[i].DATA
end

T = CM.transpose(T)

X1 = M(NF, NS)
X2 = M(NF, NS)
for i = 1, NF do
	X1[i] = V.cumsum(CV.unwrap(T[i]))
	X2[i] = V.cumsum(CV.unwrap(T[i])^2)
end

-- Now we can do the analysis.
groupsize = NS-1

v1 = V(NS - groupsize, 1, 1)
v2 = V(NS - groupsize, groupsize + 1, 1)

A1 = M(NF, NS - groupsize)
A2 = M(NF, NS - groupsize)
for i = 1, NF do
	A1[i] = X1[i][v2] - X1[i][v1]; A1[i] = A1[i] / groupsize
	A2[i] = X2[i][v2] - X2[i][v1]; A2[i] = A2[i] / groupsize
end

A = M(NF, NS - groupsize)
for i = 1, NF do
	A[i] = V.sqrt(V.abs(A2[i] - A1[i]^2))
end

A = M.transpose(A)

noise = V(ND)
noise = A[1]
noise = 20 * V.log10(noise)

-------------------------------------------
W1 = chart("NOISE04 ")

if window_manager.find(W1) then
	chart.clear(W1)
	chart.add(W1, freqs, noise, "Phase Noise")
	chart.set_xlabel(W1, "Frequency (MHz)")
	chart.set_ylabel(W1, "Noise amplitude")
	chart.set_property(W1, LINE)
	chart.update(W1)
end


