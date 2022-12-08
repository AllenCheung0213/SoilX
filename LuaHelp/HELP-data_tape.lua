-- constructors
data_tape() --> tape
data_tape(tape) --> tape

data_tape.copy_header(dst, src) --> VOID 
data_tape.append(tape, data_scan) --> VOID

-- appends t1 and t2 creating a new tape
t1 .. t2 --> t s.t. t[t1[1], ..., t2[1], ...]

-- assignment
tape[i] = data_scan

#tape --> |tape|
data_tape.size(tape) --> |tape|

-- markers
data_tape.get_markers(tape) --> LEFT_MARKER, RIGHT_MARKER
data_tape.set_markers(tape, LEFT_MARKER, RIGHT_MARKER) --> VOID

-- selectors
data_scan = tape[scanNumber]
data_tape = tape[VECTOR]
data_tape = tape[FUNCTION]

vector = tape[DATA_SCAN_SELECTOR]

	w\ DATA_SCAN_SELECTOR is any of the selectors 
	   defined for a data_scan, except DATA which
	   is subsumed by data_tape.get_matrix.

data_tape.get_scan(tape, scanNumber) --> SCAN, FRAME, SWEEP, TX, RX, TIMESTAMP
data_tape.get_sweep(tape, sweepNumber) --> VECTOR of scanNumber
data_tape.get_frame(tape, frameNumber) --> VECTOR of scanNumber

data_tape.get_matrix(tape) --> COMPLEX_MATRIX

data_tape.find_frame(tape, frameNumber) --> scanNumber
data_tape.find_sweep(tape, sweepNumber) --> scanNumber
data_tape.find_timestamp(tape, timestamp) --> scanNumber

-- management
---------------------------------------------------------------------
data_tape.find(tape, FUNCTION) --> VECTOR of scanNumber
data_tape.slice(tape, [s = 1], [f = #tape]) --> TAPE
data_tape.truncate(tape, n) --> TAPE

data_tape.rewind(tape) --> VOID
data_tape.clear(tape) --> VOID
data_tape.set_damaged(tape) --> VOID

-- predicates
---------------------------------------------------------------------
data_tape.is_compatible(tape) --> BOOL
data_tape.is_damaged(tape) --> BOOL

data_tape.is_valid_combination(tape, TX, RX) --> BOOL

-- io
---------------------------------------------------------------------
data_tape.read(filename) --> tape
data_tape.write(tape, filename) --> VOID

print(tape) --> data_tape(|tape|)

-- queries user for filename and reads/writes tape
data_tape.open() --> tape
data_tape.save(tape) --> VOID

-- the default plot title given a scan index
format(tape, i) --> "Fr Sw Tx(Sensor-#) Rx(Sensor-#) Ts"
format(tape, i) --> "Fr Sw Tx(Sensor-#)(Port-#) Rx(Sensor-#)(Port-#) Ts"

-- properties
---------------------------------------------------------------------
data_tape.get_filename(tape) --> filename
data_tape.set_filename(tape, filename) --> VOID

data_tape.get_comment(tape) --> comment
data_tape.set_comment(tape, comment) --> VOID

-- legacy: use table interface!
---------------------------------------------------------------------
data_tape.get_scan_parameters(tape) --> nPts, F0, F1, SR
data_tape.set_scan_parameters(tape, nPts, F0, F1, SR) --> void

---------------------------------------------------------------------
data_tape.get_combo_table(tape) --> SEE CONFIG

data_tape.get_encoder_parameter_table(tape) --> SEE CONFIG
data_tape.get_hardware_parameter_table(tape) --> SEE CONFIG
data_tape.get_scan_parameter_table(tape) --> SEE CONFIG
data_tape.get_sensor_table(tape) --> SEE CONFIG
data_tape.get_process_parameter_table(tape) --> SEE CONFIG

data_tape.set_encoder_parameter_table(tape, table) --> SEE CONFIG
data_tape.set_hardware_parameter_table(tape, table) --> SEE CONFIG
data_tape.set_scan_parameter_table(tape, , table) --> SEE CONFIG
data_tape.set_sensor_table(tape, table) --> SEE CONFIG
data_tape.set_process_parameter_table(tape, table) --> SEE CONFIG

---------------------------------------------------------------------
data_tape.get_freq_step(tape, [NPts, F0, F1]) --> dF
data_tape.get_time_step(tape, nFFT, [NP, F0, F1]) --> dT

-- special functions
---------------------------------------------------------------------
data_tape.apply_active_filters(tape) --> VOID