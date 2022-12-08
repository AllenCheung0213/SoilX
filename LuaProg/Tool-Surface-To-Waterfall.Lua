L = require("UTIL-Lua")
P = require("UTIL-Plot")

if SOURCE_NAME == "" then
	forms.error("Must be call from a surface or texture window only.")
	error()
end

AP = config.get_analysis_parameter_table()
--L.display("AP", AP)

type = window_manager.get_window_type(SOURCE_NAME)

fg = MODULE.get_matrix(SOURCE_NAME)
t1 = MODULE.get_title1(SOURCE_NAME)
t2 = MODULE.get_title2(SOURCE_NAME)

nPTS, F0, F1, SR = data_source.get_scan_parameters()

nFFT = AP.FFT_SIZE

dT = data_source.get_time_step(nFFT)

X = vector(nFFT, 0, dT * 0.15)

w = chart(SOURCE_NAME .. "(WTRFLL)", FL_CHART_WINDOW)

chart.clear(w)
for i = 1, #fg do
	Y = complex_vector.abs(fg[i])
	chart.add(w, X, Y, t1, "Line " .. i)
end

chart.update(w)

window_manager.register(SOURCE_NAME, PROGRAM_NAME, w)



