-- V - 4.84
-- Q - 7.56

--
-- Tool-K-THETA-Calibration
--

Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

dofile("LuaProg/UTIL-Header.lua")
dofile("LuaProg/Tool-Group-Delay-Parameters.Lua")


params = edit_parameter_table()
if params == nil then
	error("user canceled operation")
end

Lua.display(params)

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
if params.use_data_file then
	tape = DT.read(params.data_filename)
else
	tape = DS.get_tape()
end

---------------------------------------------------------------------------------------
NP, F0, F1, SR = DT.get_scan_parameters(tape)
dF = DT.get_freq_step(tape)

---------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------
function plot_analysis(v, t, isnew)
	local w = chart("ANAL", FL_ANALYSIS_WINDOW)
	chart.set_scan_parameters(w, NP, F0, F1, SR)
	if isnew then chart.clear(w) end
	chart.add(w, v, t)
	chart.update(w)
end

function plot_calibration(freq, calib)
	local w = chart("CALIB", FL_CHART_WINDOW)
	chart.clear(w)
	chart.add(w, freq, calib, DT.get_filename(tape), "Phase Calibration")
	chart.set_xlabel(w, "Frequency (mHz)")
	chart.set_ylabel(w, "Phase Correction (rad)")
	chart.update(w)
end

---------------------------------------------------------------------------------------
data = DT.get_matrix(tape)
data = CM.avg(data)

-- Plot the original data.
plot_analysis(data, "Average Data", true)

-- This configuration's frequency vector...
F = vector(NP, F0, dF)

U = complex_vector.unwrap(data)

-- The theoretical slope based upon effective antenna separation.
slope = -(params.antenna_separation / 0.30) * 2 * math.pi * dF / 1.e3

-- Evaluate the theoretical unwrapped phase.
V = vector(#F, 0, 1)
V = slope * V

-- The difference represents the calibration.
corr = V - U

-- Without a reference calibration --the result
-- is assumed to be symetric.
if params.use_reference_antenna == false then
	corr = corr / 2
end

plot_calibration(F, corr)

-- Apply the correction and show the user.
data = CV.rotate(data, corr)
--data = CV.rotate(data, corr)

-- XPlot the corrected data.
plot_analysis(data, "Corrected Data")
