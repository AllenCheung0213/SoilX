------------------------------------------------------------
-- Construction
------------------------------------------------------------
-- Chart windows are referenced by user_name that appears in
-- window title.  If unspecified, the window manager assigns
-- a name automatically.
chart(<user_type>, <user_name>, <window_type>) --> name
chart(<user_name>, <window_type>) --> name
chart(<window_type>) --> name
chart() --> name

------------------------------------------------------------
-- Predicate
------------------------------------------------------------
-- Since the window can be closed at any time, the window-name 
-- can be used to validate the window before using it.
chart.is_analysis_window(name) --> bool

------------------------------------------------------------
-- Data Manipulation
------------------------------------------------------------
chart.size(name) --> number-of-plot-lines
chart.clear(name) --> VOID

chart.add(name, complex_vector, [title], [title]) --> VOID 
chart.add(name, vector, vector, [title], [title]) --> VOID
chart.update(name) --> VOID

------------------------------------------------------------
-- Data Selectors
------------------------------------------------------------
chart.get_vector(name, [index = current_selection], [is_processed = false]) --> complex_vector, title1, title2
chart.get_matrix(name, [is_processed = false]) --> complex_matrix

chart.get_selection_vector(name) --> vector
chart.set_selection_vector(name, vector) --> VOID

------------------------------------------------------------
chart.get_marker_table(name) --> {FILENAME {LABEL, X, Y, Z} ...}
chart.set_marker_table(name, {FILENAME {LABEL, X, Y, Z} ...}) --> VOID

chart.get_marker_vector(name) --> complex_vector of (X, Y)
chart.set_marker_vector(name, complex_vector of (X, Y)) --> VOID

------------------------------------------------------------
chart.get_ground_truth_table(name) --> {FILENAME {LABEL, X, Y, Z} ...}
chart.set_ground_truth_table(name, {FILENAME {LABEL, X, Y, Z} ...}) --> VOID

chart.get_ground_truth_vector(name) --> complex_vector of (X, Y)
chart.set_ground_truth_vector(name, complex_vector of (X, Y)) --> VOID

------------------------------------------------------------
-- Analysis
------------------------------------------------------------
chart.spawn(name, analysis_type) --> VOID
chart.spawn(name) --> VOID

chart.get_analysis_type(name) --> analysis_type
chart.set_analysis_type(name, analysis_type) --> VOID

where analysis_type = 
	{
		MAGNITUDE_VS_TIME
		MAGNITUDE_VS_DISTANCE
		MAGNITUDE_VS_FREQUENCY
		PHASE_VS_FREQUENCY
		PHASE_VS_TIME
		UNWRAP_VS_FREQUENCY
		UNWRAP_VS_TIME
		I_VS_FREQUENCY
		Q_VS_FREQUENCY
		I_VS_TIME
		Q_VS_TIME
	}

chart.get_analysis_parameter_table() --> TABLE
	{ 
		FFT_SIZE
		WINDOW_FFT
		ZERO_FILL
	}

chart.set_analysis_parameter_table(TABLE) --> VOID




------------------------------------------------------------
-- IO
------------------------------------------------------------
chart.print(name) --> chart(#chart)

chart.read(filename) --> name
chart.write(name, filename) --> VOID

chart open(WINDOW_TYPE) --> name
chart.save(name) --> VOID

Note: File type is determined by file extension: .cha, .ana, .sfc, .tex

------------------------------------------------------------
-- Data Properties
------------------------------------------------------------
chart.get_scan_parameters() --> nPts, F0, F1, SR
chart.set_scan_parameters(nPts, F0, F1, SR) --> VOID

chart.get_freq_step(name, [NPts, F0, F1]) --> dF
chart.get_time_step(name, nFFT[, NP, F0, F1]) --> dT

------------------------------------------------------------
-- Chart Properties
------------------------------------------------------------
chart.set_scale(name, x0, x1, y0, y1) --> VOID

chart.set_title1(name, title, [index = 1]) --> VOID
chart.set_title2(name, title, [index = 1]) --> VOID

chart.get_title1(name, [index = 1]) --> title
chart.get_title2(name, [index = 1]) --> title

chart.set_xlabel(name, string) --> VOID
chart.set_ylabel(name, string) --> VOID

chart.set_autoscale(name, boolean) --> VOID
chart.set_property(name, property, property ...) --> VOID

  where property = LINEAR, LOG, LINE, SCATTER, SCATTER_LINE

chart.set_option(name, option, state, option, state, ...) --> VOID

  where option = MONO_STATIC, BI_STATIC, CABLE_DELAYS, DB_FREQ, DB_TIME
