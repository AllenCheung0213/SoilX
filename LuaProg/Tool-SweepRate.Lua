--
-- Tool-SweepRate.lua
--

-- Plots the sweep rate vs the frame number.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

-- The data source contains a single tape.
tape = data_source.get_tape()

if #tape == 0 then
	error("*** EMPTY TAPE ***")
end

TS = tape[TIMESTAMP]
FN = tape[FRAME_NUMBER]

SR = FN / TS

filename = data_tape.get_filename(tape)

-- Add the vector to  analysis window.
w = P(FN, SR, filename)

chart.set_xlabel(w, "Frame Number (#)")
chart.set_ylabel(w, "Sweep Rate (s)")

-- Using low level chart functions require an update.
chart.update(w)
