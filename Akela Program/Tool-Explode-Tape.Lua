--
-- Tool-Explode-Tape.lua
--
-- Generates a series of analysis windows -- one for each frame in the tape.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

 V = vector
DS = data_source
DT = data_tape
 
-- The data source contains a single tape.
tape = DS.get_tape()
filename = DT.get_filename(tape)

if #tape == 0 then
	forms.error("*** EMPTY TAPE ***")
	error()
end

-- We can index the tape for any member of a data_scan.
-- See Help for data_scan.
FN = tape[FRAME_NUMBER]

-- This will only work if the frame numbers are
-- sorted in the tape.  I points to the starting
-- locaton of each frame number in FN and tpe.
FU,I = V.unique(FN)

-- We want to delimit I so that we can loop
-- uniformally.
V.append(I, #FN + 1)

-- Simple function to make an analysis window.
function make_analysis_window()
	local w = chart(FL_ANALYSIS_WINDOW)
	chart.set_scan_parameters(w, data_tape.get_scan_parameters(tape))
	return w
end

-- Here's where we loop over each 'frame-slice' of the tape.
for i = 1, #I - 1 do
	w = make_analysis_window()
	for j = I[i], I[i+1] - 1 do
		P.append(w, tape[j].DATA, tape[j].FORMAT, filename)
	end
end

