system.pause() --> VOID
system.yield() --> VOID
system..sleep(ms) --> VOID
system.get_UTC_time() --> INTEGER

system.get_initial_position() --> COMPLEX

system.get_sweep_position(sweep_number) --> COMPLEX
system.get_sweep_velocity(sweep_number) --> NUMBER
system.get_sweep_position_change(sweep_number) --> COMPLEX
system_get_sweep_position_table_size() --> INTEGER

system.get_sweep_position_table() --> 
	{
		FRAME_NUMBER,
		SWEEP_NUMBER,
		TIME_STAMP,
		SWEEP_DELAY,
		X,
		Y,
		Z,
		THETA
	}

system.set_working_data_dir(dir) --> VOID
system.set_working_analysis_dir(dir) --> VOID

system.get_working_data_dir() --> string
system.get_working_analysis_dir() --> string

system.register_script_file(filename) --> VOID