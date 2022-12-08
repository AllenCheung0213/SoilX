--
-- Tool-Xplot-Tape.lua
--

-- Cross plots the entire tape in a single analysis window.

-- NOTE:
--	This script can easily be modified to provide a dialog that would define
--	a set of filter parmeters resulting in a subset of the tape being used.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector
 
CM = complex_matrix

-- The data source contains a single tape.
tape = data_source.get_tape()

if #tape == 0 then
	forms.error("*** EMPTY TAPE ***")
	error()
end

-- There's stuff in the tape, so make a window.
-- Let the system name it, so we get a new one every time.
-- NOTE:
--	The window manager can be used to make the window
--	and lock it at the same time.
w = chart(FL_ANALYSIS_WINDOW)

-- Going to need the scan parameters for the analysis window.
ND, F0, F1, SR = data_tape.get_scan_parameters(tape)

-- Might as well do it.
chart.set_scan_parameters(w, ND, F0, F1, SR)

-- We want to limit very large virtual files.
M0, M1 = data_tape.get_markers(tape);

if M1 - M0 > 100 then
	M1 = math.min(M0 + 100, #tape)
end

print(string.format("M0 = %d  M1 = %d", M0, M1))

-- Now we can iterate over the tape and add each scan to our window.
for i = 1, #tape do

	-- We get the scan by indexing the tape.
	S = tape[i]

	-- Need to make a generic label for each scan.
	-- We can get it by indexing the scan object.
	T = S.FORMAT

	-- Add the scan to te analysis window.
	chart.add(w, S.DATA, T, data_tape.get_filename(tape))
end

-- Using low level chart functions require an update.
chart.update(w)
