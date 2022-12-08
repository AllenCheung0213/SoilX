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

tape = tape[ function(S) return S.RX == 3 end ]

LSE = tape[ENCODER_LSE]
RSE = tape[ENCODER_RSE]
THETA = tape[ENCODER_THETA]

X = tape[ENCODER_X]
Y = tape[ENCODER_Y]
TS = tape[TIMESTAMP]
SW = tape[SWEEP_NUMBER]

filename = data_tape.get_filename(tape)

P(SW, LSE, "LSE", filename)
P(SW, RSE, "RSE", filename)

P(LSE, RSE, "LSE vs RSE", filename)

P(THETA, "THETA", filename)

P(X, Y, "Y vs X", filename)