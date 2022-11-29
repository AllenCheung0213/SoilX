-- initialization
data_source.reset() --> VOID		-- rease and reprogram radar
data_source.erase() --> VOID		-- erase only

data_source.size() --> number of scans currently stored in memory

-- markers
data_source.get_markers() --> LEFT_MARKER, RIGHT_MARKER
data_source.set_markers(LEFT_MARKER, RIGHT_MARKER) --> VOID

-- selection
data_source.get_tape() --> global_data_tape
data_source.set_tape(data_tape) --> void

data_souce.get_matrix() --> complex_matrix

-- attributes
data_source.get_filename() --> data_source_name
data_source.set_filename(data_source_name) --> data_source_name

data_source.get_scan_parameters() --> nPts, F0, F1, SR

data_source.get_freq_step([NPts, F0, F1]) --> dF
data_source.get_time_step(nFFT, [NP, F0, F1]) --> dT

-- control
data_source.collect(EOF) --> data_tape(1 .. EOF)

data_source.collect(N) --> data_tape(1 .. N)
data_source.collect(TMAX, MULTI_FRAME) --> data_tape(TOTAL-TIME-COLLECTED <= TMAX)
data_source.collect(NFRAME, SINGLE_FRAME) --> data_tape(1 .. NFRAME)
data_source.collect(NSWEEP, SINGLE_SWEEP) --> data_tape(1 .. NSWEEP)
data_source.collect(NCOMBO, SINGLE_COMBO) --> data_tape(1 .. NCOMBO)

data_source.collect(N, function(S)) --> data_tape(1 .. N) s.t. F(S) == true
data_source.collect(F) --> data_tape(1 .. EOF) s.t. F(S) == true

	Note: All collect functions append to the current
	      data tape.  User must either reset or erase
	      before using.
	  
data_source.get_type() --> DATA_FILE | HARDWARE | UDP_DATA_SOURCE
data_source.set_type(DATA_FILE | HARDWARE | UDP_DATA_SOURCE) --> type

-- programming
data_source.is_active() --> BOOL
data_source.status_stitch_point(BOOL) --> VOID
