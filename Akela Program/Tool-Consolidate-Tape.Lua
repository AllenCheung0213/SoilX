--
-- Tool-Consolidate-Tape.lua
--

L = require("UTIL-Lua")
Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

dofile("LuaProg/UTIL-Header.lua")

SL = config.get_sensor_table()
CL = config.get_combo_table()

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function index_combination(TX, RX)
	for i = 1, #CL do
		if TX == CL[i].TX and RX == CL[i].RX then
			return i
		end
	end
	error(string.format("unable to find combination (TX,RX) = (%d, %d)", TX, RX))
end

---------------------------------------------------------------------------------------
function get_consolidated_matrix(tape)
	
	I = {}
	for i = 1, #CL do
		I[i] = V()
	end

	for i = 1, #tape do
		S = tape[i] ; c = index_combination(S.TX, S.RX)
		I[c] = I[c] .. i
	end

	cm = CM()
	for i = 1, #CL do
		CM.append(cm, CM.avg(DT.get_matrix(tape[I[i]])))
	end

	return cm
end

---------------------------------------------------------------------------------------
function make_consolidated_tape(tape, cm)

	local DS = data_scan
	local CL = config.get_combo_table()

	DT.clear(tape)
	for i = 1, #CL do

		S = DS()

		S.FRAME_NUMBER = 1
		S.SWEEP_NUMBER = CL[i].TX
		S.TX = CL[i].TX
		S.RX = CL[i].RX
		S.TX_PORT = SL[S.TX].PORT
		S.RX_PORT = SL[S.RX].PORT
		S.TIMESTAMP = 0.0
		S.DATA = cm[i]
	
		DT.append(tape, S)
	end
	return tape
end


-- The data source contains a single tape.
---------------------------------------------------------------------------------------
tape = data_source.get_tape()

if #tape == 0 then
	forms.error("*** EMPTY TAPE ***")
	error()
end

cm = get_consolidated_matrix(tape)
tape = make_consolidated_tape(tape, cm)

dofile("LuaProg/Tool-XPlot-Tape.lua")
