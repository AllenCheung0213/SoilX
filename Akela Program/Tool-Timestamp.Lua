--
-- Tool-TimeStamp.lua
--

-- Plots the timestamp vs frame number.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

-- The data source contains a single tape.
tape = data_source.get_tape()

if #tape == 0 then
	error("*** EMPTY TAPE ***")
end

TS = tape[TIMESTAMP]
FN = tape[FRAME_NUMBER]

filename = data_tape.get_filename(tape)

w = P(FN, TS, filename)

chart.set_xlabel(w, "Frame Number (#)")
chart.set_ylabel(w, "Timestamp (s)")

-- Using low level chart functions require an update.
chart.update(w)
