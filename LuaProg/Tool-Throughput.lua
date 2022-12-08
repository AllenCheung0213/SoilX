--
-- Tool-Throughput.lua
--

-- Plots the percentage scan efficiency vs the scan number.

L = require("UTIL-Lua")
P = require("UTIL-Plot")

CV = complex_vector
 V = vector

CM = complex_matrix

-- The data source contains a single tape.
tape = data_source.get_tape()

if #tape == 0 then
	forms.error("Empty data buffer.")
end

-- We need the sweep definition because if there are
-- excluded bands, then the number of points actually 
-- scanned is reduced.
SD = config.get_sweep_definition_table()
SL = config.get_sensor_table()

M0, M1 = data_tape.get_markers(tape);

NL = 100 * #SL
ML = math.min(M0 + NL, #tape)

print(string.format("M0 = %d  M1 = %d", M0, M1))

TS = tape[TIMESTAMP]

--P(TS)

dT = V.diff(TS)

-- Need to get rid of any zeroes in dT.
dT = dT[ function(x) return x > 1e-3 end ]

--P(dT)

sweep_rate_expected = SD.SWEEP_RATE / SD.NPOINTS_EXPECTED * SD.NPOINTS_PER_SAMPLE

-- Convert to % efficiency
eff = 100 * SD.NPOINTS_PER_SAMPLE / dT / sweep_rate_expected

-- Since the timestamp is sampled before the radar sweeps, some
-- of the data results in eff greater than 100 percent. 

-- Some useful stuff to display in the title.
T1 = string.format("Throughput: %.1f (sweeps / sec)",  sweep_rate_expected)

-- Get some statistics using v. Remember to re index with I
T2 = string.format("Min: %.1f  Max: %.1f  Avg: %.1f  Std: %.1f", V.stats(eff));

filename = data_tape.get_filename(tape)

-- NOTE:
--	The window manager can be used to make the window
--	and lock it at the same time. In this case we don't
--  because we probably want to cross-plot the charts.
w = chart()

-- Make sure the chart is empty.
chart.clear(w)

-- Add the vector to  analysis window.
chart.add(w, V(#eff, M0, 1), eff, T1 .. "  " .. T2, filename)
chart.set_xlabel(w, "Scan Number (#)")
chart.set_ylabel(w, "Efficiency (%)")

chart.set_scale(w, M0, M0 + #eff, 0, 100)
chart.set_autoscale(w, false)

-- Using low level chart functions require an update.
chart.update(w)
