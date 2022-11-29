-- construction
hardware() --> object
hardware(port) --> object
hardware(port, timeout) --> object

--- status
hardware.is_listening(object, IP) --> bool
hardware.is_programmed(object, IP) --> bool

-- control
hardware.quit(object, IP) --> void
hardware.linefeed(object, IP) --> void

-- IO
hardware.read(object) --> data_packet
hardware.write(object, IP. message) -> void
hardware.flush() --> void

-- memory
hardware.get_memory(object, IP, addr) --> integer
hardware.set_memory(object, IP, addr, cmd, arg) --> void

-- sweep
hardware.sweep(object, IP, [ offset, [x, y] ]) --> void

-- registers
hardware.get_register(object, IP, reg) --> integer:val
hardware.set_register(object, IP, reg, val)

-- utilities
hardware.set_broadcast_address(object, IP) --> void
hardware.get_radar_version(object, IP) --> version

print(object) --> hardware(port, timeout))

-- extended functions
hardware.create_program(object, sensor_type) --> void
hardware.read_program(object, lua_filename) --> void

Note:	
	Both create_program and read_program creates an internal
	program object capable of building and programming
	the radar by calling build_program.

hardware.build_program(object) --> void
hardware.build_program(object, sensor_index) --> void

hardware.get_program(object) --> hex_formatted_string
hardware.send_program(object, sensor_index) --> void

hardware.get_sweep_address(sensor_index) --> integer

Note:	Must call build_program before using get_sweep_address
