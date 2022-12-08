--
-- Tool-K-THETA-Generate
--

Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

dofile("LuaProg/UTIL-Header.lua")

DT = data_tape
DS = data_scan

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
SL = config.get_sensor_table()
CL = config.get_combo_table()
AP = config.get_analysis_parameter_table()

--Lua.display("CL", CL)

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--[[
text_window = window_manager.make(FL_TEXT_WINDOW)
text_buffer = {}

for i = 1, 10 do
	text_buffer[i] = "*"
end

function set_window_text(i, line)
	text_buffer[i] = line
	window_manager.update(text_window, text_buffer)
end
--]]


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
function plot_surface(A)
	local s = surface()
	surface.set(s, A)
end

-----------------------------------------------------------------------------
function plot_frequency(F, F0, F1, SR)
	w = chart(FL_ANALYSIS_WINDOW)
	chart.clear(w)
	chart.set_scan_parameters(w, #F, F0, F1, SR)
	chart.add(w, F)
	chart.update(w)
end

-----------------------------------------------------------------------------
function cross_plot_tape(tape, filename)
	local w = chart(FL_ANALYSIS_WINDOW)
	chart.set_scan_parameters(w, data_tape.get_scan_parameters(tape))
	chart.clear(w)
	for i = 1, #tape do
		chart.add(w, tape[i].DATA, tape[i].FORMAT, filename)
	end
	chart.update(w)
end

-----------------------------------------------------------------------------
function cross_plot_matrix(m)
	local w = chart()
	for i = 1, #m do
		cv = CV.dec(m[i])
		chart.add(w, V(#cv, 1, 1), cv)
	end
	chart.update(w)
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
function get_tape(params)

	local DS = data_source
	local RP = radar_program

	-- We need these so we can restore APRD state.
	data_nulling = config().DATA_NULLING
	remove_stitch_point = config().STITCH_POINT_REMOVE

	-- If the user has specified stitch points, we want
	-- to make sure that they are not removed from the
	-- data. They will need to be incorporated into the 
	-- nulling file.  However, if this module is going to be
	-- used as a background file, then we will want to remove
	-- the stitch point.
	DS.remove_stitch_point(params.remove_stitch)

	-- This prevents the system from normally attempting
	-- to read a nulling file and send it to the radar.
	RP.enable_nulling_calibration(true)

	-- This causes the radar program to assemble the
	-- correct protocol.
	config().DATA_NULLING = false

	-- This initializes the data source and programs
	-- the radar.
	DS.set_type(HARDWARE)
	DS.reset()

	local nframe = params.nframe_warmup + params.nframe_retain

	-- We can collect all the data we want with a 
	-- single call to the data source.
	local tape = DS.collect(nframe, SINGLE_FRAME)

	-- Put everything back the way it was.
	RP.enable_nulling_calibration(false)

	-- Restore APRD state.
	config().DATA_NULLING = data_nulling
	config().STITCH_POINT_REMOVE = remove_stitch_point

	return DT.slice(tape, params.nframe_warmup / 2 + 1)
end


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
function N2Order(n)
	return math.ceil(math.log10(n) / math.log10(2))
end

-----------------------------------------------------------------------------
function Order2N(order)
	return 2 ^ order
end

-----------------------------------------------------------------------------
function get_dc_component(tape)

	--cross_plot_tape(tape)

	local nActualPoints = #tape[1]
	--print("nActualPoints", nActualPoints)

	local nPoints, F0, F1, SR = data_tape.get_scan_parameters(tape)
	--print(nPoints, F0, F1, SR)

	local freq_matrix = data_tape.get_matrix(tape)
	--print("freq_matrix", freq_matrix)

	local nScan = Order2N(math.floor(N2Order(#tape)))
	freq_matrix = CM.truncate(freq_matrix, nScan)
	--print("nScan", nScan)

	local nFFTPoints = AP.FFT_SIZE
	--print("nFFTPoints", nFFTPoints)

	local time_matrix = CM.fft(freq_matrix, nFFTPoints, F0, F1, false, true)
	--print("time_matrix", time_matrix)

	-- Doppler	
	local doppler_matrix = CM.transpose(time_matrix)
	doppler_matrix = CM.fft(doppler_matrix, nScan, false, false)
	doppler_matrix = CM.transpose(doppler_matrix)
	--print("doppler_matrix", doppler_matrix)

	----------------------------------------
	--plot_surface(doppler_matrix)
	----------------------------------------

	-- Extract the DC component.
	local dc_component = doppler_matrix[1] ; 
	--print("dc_component", dc_component)
	
	local freq_vector = CV.fft(dc_component, nFFTPoints, false, false)
	
	local fStep = (F1 - F0) / (nPoints - 1);
	local nZeros = math.floor(F0 / fStep)
	--print("nZeros", nZeros)

	freq_vector = CV.slice(freq_vector, nZeros + 1, nZeros + nActualPoints)
	freq_vector = freq_vector / nScan
	--print("freq_vector", freq_vector)

	-------------------------------------------
	--plot_frequency(freq_vector, F0, F1, SR)
	-------------------------------------------

	return freq_vector
end

-----------------------------------------------------------------------------
function index_combination(TX, RX)
	for i = 1, #CL do
		if TX == CL[i].TX and RX == CL[i].RX then
			return i
		end
	end
	error(string.format("unable to find combination (TX,RX) = (%d, %d)", TX, RX))
end

-----------------------------------------------------------------------------
function get_consolidated_matrix(tape)
	
	I = {}
	for i = 1, #CL do
		I[i] = V()
	end

	for i = 1, #tape do
		S = tape[i] ; c = index_combination(S.TX, S.RX)
		I[c] = I[c] .. i
	end

	m = CM()
	for i = 1, #CL do
		print("icombo, TX, RX", i, CL[i].TX, CL[i].RX)
		if params.use_average == true then
			CM.append(m, CM.avg( data_tape.get_matrix(tape[I[i]]) ) )
		else
			collectgarbage("collect")
			CM.append(m, get_dc_component( tape[I[i]] ) )
		end
	end
	
	return m

end

-----------------------------------------------------------------------------
function make_consolidated_tape(tape, cm)
	local DS = data_scan
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


-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
dofile("LuaProg/Tool-K-THETA-Parameters.Lua")

params = get_parameters()
if params == nil then
	error()
end

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
if params.use_memory then
	tape = data_source.get_tape()
else
	tape = get_tape(params)
end

cm = get_consolidated_matrix(tape)
--print(cm)

tape = make_consolidated_tape(tape, cm)
--print(tape)

cross_plot_tape(tape, params.use_memory == false and SL.DATA_NULLING_PATH or "UNKNOWN FILENAME")

-----------------------------------------------------------------------------
if params.use_memory == false then
	print("Writing Nulling File:" .. SL.DATA_NULLING_PATH)
	DT.write(tape, SL.DATA_NULLING_PATH)
end
