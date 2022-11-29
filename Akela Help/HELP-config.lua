-- IO
config.open() --> VOID
config.save() --> VOID
config.saveas(filename) --> VOID
config.read(filename) --> VOID
config.write(filename) --> VOID

-- configuration tables
---------------------------------------------------------------------
config.get_hardware_parameter_table() --> 
	{ 
		ADJUST_CLOCKS,
		CONVERTER_CORRECTION,
		FREQ_OFFSET,
		FREQ_OFFSET_VALUE,
		GAIN_ADJUST,
		GLOBAL_GAIN_VALUE,
		GLOBAL_GAIN_STATUS,
		GPS_ENABLED_1,
		GPS_IP_1,
		GPS_ENABLED_2,
		GPS_IP_2,
		LNA,
		NORMALIZE_DATA,
		PLL_BASE,
		PLL_DIVIDER,
		PLL_USE_TABLE,
		PLL_PATH,
		POWER_AMP,
		POWER_AMP_ATTEN,
		POWER_AMP_ATTEN_VALUE,
		SEND_EXCLUDED_POINT,
		STITCH_POINT,
		STITCH_POINT_REMOVE,
		STATUS_TX,
		TIME_SYNC,
		TIME_SYNC_DELAY,
		COMMENT_0,
		COMMENT_1,
		COMMENT_2,
		COMMENT_3,
		COMMENT_4,
		COMMENT_5,
		COMMENT_6,
		COMMENT_7,
		COMMENT_8,
		COMMENT_9
	}

config.set_hardware_parameter_table(TABLE) --> VOID

---------------------------------------------------------------------
config.get_scan_parameter_table() --> 
	{ 
		SCAN_SIZE, 
		START_FREQ, 
		STOP_FREQ, 
		SWEEP_RATE 
	}
	
config.set_scan_parameter_table(TABLE) --> VOID

---------------------------------------------------------------------
config.get_sensor_table() --> 
	{ 
		MASTER_INDEX,
		PSEUDO_MASTER_INDEX,
		IS_PSEUDO_MASTER_PRESENT,
		DATA_NULLING,
		DATA_NULLING_PATH,
		ANTENNA_SWITCH,
		ALTERNATE_TX,
		ALTERNATE_RX,
		ALTERNATE_TXRX, 
		{SENSOR, SENSOR, ... } }

		where SENSOR -->
		{ 
			ENABLE,			-- bool
			TYPE,			-- GENERIC, ARRAY_ ...
			ID, 
			IP,				
			GAIN, 
			PORT,			-- int: 1, 2,...
			TX_PORT,		-- int: 1, 2,...
			RX_PORT,		-- int: 1, 2,...
			TX_DELAY, 
			RX_DELAY, 
			TX,				-- bool
			RX,				-- bool
			MONO,			-- bool
			X,				-- initial location
			Y, 
			Z,
			NULLING_K,		-- calibration
			NULLING_THETA,
			CURR_X,			-- useful during processing
			CURR_Y,
			CURR_Z,
			CURR_T,
			CURR_V,
			CURR_LSE,
			CURR_RSE,
			VERSION,
		}
	}

config.set_sensor_table(TABLE) --> VOID

---------------------------------------------------------------------
config.get_port_assignment_table() -->
	{ 
		{PORT, NAME, ALIAS}, {PORT, NAME, ALIAS}, ...
	}

config.set_port_assignment_table() --> VOID


---------------------------------------------------------------------
config.get_process_parameter_table() -->
	{ 
		ENABLE_GATE_VALUES, 
		GATE_TX1, 
		GATE_TX1_RX1, 
		GATE_RX1, 
		GATE_RX1_RX2, 
		GATE_RX2, 
		GATE_RX2_TX1 
	}

config.set_process_parameter_table() --> VOID


---------------------------------------------------------------------
config.get_encoder_parameter_table() -->
	{
		USE_ENCODER,
		USE_GPS,
		USE_TELEMETRY,
		{
			ENABLE,
			COUNTS_PER_REVOLUTION,
			NSHAFT_COUNTS,
			WHEELBASE,
			WHEEL_CIRCUMFERENCE,
			IP,
			ENCODER_TYPE		-- 
			OFFSET_X,
			OFFSET_Y,
			WHEEL_RATIO
		} ...
	}

config.set_encoder_parameter_table(TABLE) --> VOID


---------------------------------------------------------------------
---------------------------------------------------------------------
config.get_system_parameter_table() --> 
	{ 
		PRODUCT_TYPE				-- STATIONARY_ARRAY, MOBILE_ARRAY_ ...
		SOURCE_TYPE					-- DATA_FILE, HARDWARE ...
		SOURCE_NAME
		SINK_TYPE					-- DATA_SINK_BIN, DATA_SINK_MEM ...
		SWEEP_TYPE					-- MULTI_FRAME, SINGLE_ ...
		RECORD_DATA					-- bool
		MAX_TIME
		NFRAMES
		NSWEEPS
		NSCANS
		DATA_FILENAME
		SAVE_DATA					-- bool
		AUTO_INCREMENT_FILENAME
		REPEAT						-- bool
	}

config.set_system_parameter_table(TABLE) --> VOID

---------------------------------------------------------------------
config.get_analysis_parameter_table() --> 
	{ 
		USE_GROUND_TRUTH,
		GROUND_TRUTH_PATH

		USE_COORD_LIST
		COORD_LIST_PATH

		FFT_SIZE
		WINDOW_FFT
		ZERO_FILL

		IMAGE_TYPE
		SLICE_TYPE
		IMAGE_DEPTH
	
		CELL_SIZE
		CELL_FACTOR
	
		COLOR_MAP_TYPE
		MIN_THRESHOLD
		MAX_THRESHOLD

		BACKGROUND_BLEND
		AUTO_THRESHOLD
		MIN_MAX_SCALE

		DISTANCE_CORRECTION

		USER_SCALE
		MIN_INTENSITY
		MAX_INTENSITY

		USE_INDEX_OF_REFRACTION
		INDEX_OF_REFRACTION

		XY = { W0, W1, H0, H1, D0 }
		XZ = { W0, W1, H0, H1, D0 }
		YZ = { W0, W1, H0, H1, D0 }
	}

	Note that slices are tables containing generic terms 
	for height, width and depth in context of the slice.

---------------------------------------------------------------------
config.set_analysis_parameter_table(TABLE) --> VOID


config.get_sweep_definition_table(TYPE) --> 
	{
		SCAN_SIZE,
		START_FREQ,
		STOP_FREQ,	
		SWEEP_RATE,
		NPOINTS_EXPECTED,
		NPACKETS_EXPECTED,
		NPOINTS_PER_PACKET,
		NPOINTS_PER_SAMPLE,
		{{ STATUS, EXTRA, FREQ } ... }
	 }

  where TYPE = DATA | OSYNC | MSYNC
  

config.get_filter_parameter_table() --> 
	{
		BACKGROUND_TYPE,
		BACKGROUND_PATH,
		BACKGROUND_SCAN_SIZE
	}
config.set_filter_parameter_table(TABLE) --> VOID

-- combinations
-------------------------------------------------------------------------
config.get_combo_table() --> { {TX, RX}, ... }

config.is_valid_combination(TX, RX) --> BOOL
config.get_combo_index(TX, RX) --> INTEGER

-- legacy: use table interface!
-------------------------------------------------------------------------
config.get_scan_parameters() --> SIZE, F0, F1, RATE
config.set_scan_parameters(SIZE, F0, F1, RATE) --> --> SIZE, F0, F1, RATE

