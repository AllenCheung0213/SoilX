L = require("LuaProg/UTIL-Lua")

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

print("ND, NS = ", ND, NS)

---------------------------------------------
---------------------------------------------
-- Need to drag out all the scans so the matrix can be inverted.
T = CM(NS, NF)

for i = 1, NS do
	T[i] = tape[i].DATA
end

T = CM.transpose(T)

X1 = CM(NF, NS)
X2 = CM(NF, NS)


for i = 1, NF do
	X1[i] = CV.cumsum(T[i])
	X2[i] = CV.cumsum(T[i]^2)
end

L.display(X1[1])

-- Now we can do the analysis.
groupsize = 10

v1 = V(NS - groupsize, 1, 1)
v2 = V(NS - groupsize, groupsize + 1, 1)

A1 = CM(NF, NS - groupsize)
A2 = CM(NF, NS - groupsize)
for i = 1, NF do
	A1[i] = X1[i][v2] - X1[i][v1]; A1[i] = A1[i] / groupsize
	A2[i] = X2[i][v2] - X2[i][v1]; A2[i] = A2[i] / groupsize
end

A = M(NF, NS - groupsize)
for i = 1, NF do
	A[i] = V.sqrt(CV.abs(A2[i] - A1[i]^2))
end

A = M.transpose(A)


-------------------------------------------
print("stats = ", M.stats(A))

filename = string.gsub(data_tape.get_filename(tape), ".+[/\\]", "")

x, y = M.hist(A, 64)

hist = plot("HIST", filename .. " HIST-01", x, V.norm(y), "Histogram" )

chart.set_xlabel(hist, "MAG(STD)")
chart.set_ylabel(hist, "Relative Ocurrence")

-------------------------------------------
p = surface("IMAGE", filename .. " MAG(STD)")
surface.set(p, A, true)

if F0 == F1 then
	forms.message("warning: start and stop frequencies are the same")
end

S, Fr, Sw, Tx, Rx, T0 = data_tape.get_scan(tape, 1)
S, Fr, Sw, Tx, Rx, T1 = data_tape.get_scan(tape, NS - groupsize)

print (F0, F1, T0, T1)

surface.set_scale(p, F0, F1, 0.0, T1 - T0)
surface.set_title1(p, "Magnitude of the Standard Deviation")
surface.set_title2(p, data_tape.get_filename(tape))
surface.set_xlabel(p, "Frequency (MHz)")
surface.set_ylabel(p, "MAG(STD)")
surface.update(p)

--window_manager.tile()


