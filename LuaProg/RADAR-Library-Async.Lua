--
-- RADAR-Library-Async.lua
--

-- Contains all the default function definitions for
-- writing a Radar Progam.  Other radar program files need
-- to "include" this file using dofile("RADAR-Library-Async.lua")
-- and, if necessary, locally redefining any funtion.

L = require("LuaProg/UTIL-Lua")
RP = radar_program

SL = config.get_sensor_table()
SD = config.get_sweep_definition_table()
HP = config.get_hardware_parameter_table()
PP = config.get_process_parameter_table()
SP = config.get_scan_parameter_table()
CL = config.get_combo_table()
SX = config.get_sweep_table()

--L.display("SD:", SD)
--L.display("SL:", SL)
--L.display("CL:", CL)
--L.display("HP", HP)
--L.display("PP", PP)
--L.display("SP", SP)

if HP.PLL_USE_TABLE then
	PLLTable = file.read_matrix(HP.PLL_PATH)
end

--L.display(PLLTable)

--print("SX:")
--for k in pairs(SX) do
--	L.display(k, SX[k])
--end

NULLING_MASK = RP.get_nulling_mask(RADAR_PROGRAM)

print("NULLING_MASK = ", NULLING_MASK)

---------------------------------------------------------------------
-- Low level program interface
---------------------------------------------------------------------
function SET_PC(x) RP.set_program_counter(RADAR_PROGRAM, x) end
function SET(...) RP.set_memory(RADAR_PROGRAM, ...) end

function GET_VERSION(index) return RP.get_version(RADAR_PROGRAM, SL[index].IP) end

function GET_SWEEP_INDEX(rate) return RP.get_sweep_index(rate) end

function IS_GLOBAL_GAIN() return RP.is_global_gain() end
function GET_GLOBAL_GAIN() return RP.get_global_gain() end

function IS_SWITCHED() return RP.is_switched() end

function IS_TX_ALTERNATED() return RP.is_tx_alternated() end
function IS_RX_ALTERNATED() return RP.is_rx_alternated() end
function IS_TXRX_ALTERNATED() return RP.is_txrx_alternated() end

function IS_TRANSMITTER_ENABLED() return RP.is_transmitter_enabled() end

function SET_GATE_VALUES() RP.set_gate_values(); end

---------------------------------------------------------------------
-- Band boundary functions
---------------------------------------------------------------------r
function GET_BAND_TYPE() return RP.get_band_type() end
function SET_LOWER_BAND() RP.set_band_type(FREQ_BAND_2) end
function SET_UPPER_BAND() RP.set_band_type(FREQ_BAND_3) end
function SET_BAND_TYPE(f) RP.set_band_type(f) end

function IS_LOWER_BAND() return RP.is_lower_band() end
function IS_UPPER_BAND() return RP.is_upper_band() end
function IS_BAND_TRANSITION(f) return RP.is_band_transition(f) end

---------------------------------------------------------------------
-- Antenna boundary functions
---------------------------------------------------------------------
function GET_ANTENNA_TYPE() return RP.get_antenna_type(RADAR_PROGRAM) end
function SET_ANTENNA_TYPE(v) RP.set_antenna_type(RADAR_PROGRAM, v) end

function IS_ANTENNA_TRANSITION(f) return RP.is_antenna_transition(RADAR_PROGRAM, f) end

function IS_LOWER_ANTENNA() return RP.is_lower_antenna(RADAR_PROGRAM) end
function IS_UPPER_ANTENNA() return RP.is_upper_antenna(RADAR_PROGRAM) end

function IS_LOW_SIDE_LO() return RP.is_low_side_lo(RADAR_PROGRAM) end

---------------------------------------------------------------------
-- Program addresses
---------------------------------------------------------------------
function GET_SWEEP_ADDR(i) return RP.get_sweep_address(RADAR_PROGRAM, i) end
function SET_SWEEP_ADDR(v) RP.set_sweep_address(RADAR_PROGRAM, v) end

function SET_OSYNC_ADDR(v) RP.set_osync_address(v) end
function SET_MSYNC_ADDR(v) RP.set_msync_address(v) end
function SET_POWER_ON_ADDRESS(v) RP.set_power_on_address(v) end
function SET_POWER_OFF_ADDRESS(v) RP.set_power_off_address(v) end

function GET_NULLING_OFFSET(i) return RP.get_nulling_offset(RADAR_PROGRAM, i) end
		
---------------------------------------------------------------------
-- Misc macros I
---------------------------------------------------------------------
function STOP() 
	SET(0xFF) 
end

function POWER_UP(isTransmitting)

	function ShouldDisableTX(isTransmitting)
		--User overrides everything.
		if IS_TRANSMITTER_ENABLED() == false then
			return true
		end
		
		if isTransmitting == false then
			return true
		end
		
		return false;
	end

	ANTENNA_MASK = IS_LOWER_ANTENNA() and 0x20 or 0x00;
	
	band = GET_BAND_TYPE()

	if band == FREQ_BAND_1 then
		ANTENNA_MASK= _OR(ANTENNA_MASK, 0x46)
	elseif band == FREQ_BAND_2 then
		ANTENNA_MASK = _OR(ANTENNA_MASK, 0x06)
	elseif band == FREQ_BAND_3 then
		ANTENNA_MASK = _OR(ANTENNA_MASK, 0x07)
	else
		error("invalid frequency band type")
	end
	
	if ShouldDisableTX(isTransmitting) then
		ANTENNA_MASK = _XOR(ANTENNA_MASK, 0x02)
		ANTENNA_MASK = _XOR(ANTENNA_MASK, 0x08)
	else
		ANTENNA_MASK = _OR(ANTENNA_MASK, 0x02)
		ANTENNA_MASK = _OR(ANTENNA_MASK, 0x08)
	end
	
	SET(0x80, ANTENNA_MASK)
end

function POWER_DOWN()
	SET(0x80, _OR(IS_LOWER_BAND() and 0x04 or 0x05, NULLING_MASK))
end

function SET_GAIN(i) 
	if (IS_GLOBAL_GAIN()) then
		SET(0x81, _AND(GET_GLOBAL_GAIN(), 0x0f)) 
	else
		SET(0x81, _AND(SL[i].GAIN, 0x0f)) 
	end
end

function SET_DELAY(i)
	--one delayCount = 40.96 us
	--SET(0x88, 3 * (i - 1))
	
	-- The need to calculate a delay is only true for wireless
	-- systems.  The calculation is a function of points/packet, 
	-- sweep rate and sensor number.  Can cause serious communication
	-- errors that are hard to debug.
	SET(0x88, 0)
end

function SET_ENCODER_CONTROL()
	if HP.GPS_ENABLED_1 or HP.GPS_ENABLED_2 then
		SET(0x87, 0x08)
		if SP.SWEEP_RATE == 90000 then
			SET(0xFD)
		end
	end
	SET(0x87, 0x01)
	SET(0xFE)
end

function JUMP_ABSOLUTE(dest)
	SET(0x90, _AND(_SR(dest, 8), 0x00ff))
	SET(0x91, _AND(dest, 0x00ff))
end

function CALL_ABSOLUTE(dest)
	SET(0x90, _AND(_SR(dest, 8), 0x00ff))
	SET(0x93, _AND(dest, 0x00ff))
end

function RETURN()
	SET(0x95)
end

function SET_SWEEP_RATE(rate) 
	SET(0x85, GET_SWEEP_INDEX(rate))
	SET(0x84, 0x08)
end

function SET_GAIN_OFFSET(offset) 
	SET(0x83, offset) 
end

function HAS_MULTIPLIER(V) return V > 128 end

function SET_TX_MULT(V) 
	SET(0x1E, HAS_MULTIPLIER(V) and 0x05 or 0x20)
end

function SET_RX_MULT(V) 
	SET(0x5E, HAS_MULTIPLIER(V) and 0x05 or 0x20)
end

function RESET_FRAME_COUNTER()
	SET(0x87, 0x02)
end



---------------------------------------------------------------------
-- Misc macros II
---------------------------------------------------------------------
function BUILD_STARTUP_SEQUENCE(sensorIndex)
	SET_GAIN_OFFSET(00) 
	SET_SWEEP_RATE(SP.SWEEP_RATE) 

	local version = GET_VERSION(sensorIndex)

	-- Size of telemetry report.
	if version < 0x50 then
		SET(0x8E, 0xFE)
	else
		SET(0x8E, 0x7F)
	end
	
	-- PLL setup.
	if version < 0x4f then
		d = HP.PLL_DIVIDER
		//if d == 50 or d == 80 then
			//SET(0x9D, 0x02)
		//else
			//SET(0x9D, 0x00)
		//end
	else
		SET(0x9D, 0x02)
		SET(0xB4, HP.PLL_DIVIDER)
		SET(0x84, 0x01)
		DELAY(1)
	end
	DELAY(1)
	SET(0x75, 0x00) 
	SET(0x74, 0x00) 
	SET(0x35, 0x00) 
	SET(0x34, 0x00) 
	DELAY(1) 
	SET(0x33, 0x08) 
	SET(0x32, 0x02) 
	SET(0x31, 0x00) 
	SET(0x30, 0x00) 
	SET(0x73, 0x08) 
	SET(0x72, 0x02) 
	SET(0x71, 0x80) 
	SET(0x70, 0x00) 
	DELAY(1)
	--Independent units only!
	--SET(0x8C, 0x08)
end

---------------------------------------------------------------------
-- Sweep point functions
---------------------------------------------------------------------
NPOINTS_SENT = 0
function BEGIN_SWEEP_MACRO()
	NPOINTS_SENT = 0
end

function SEND_SWEEP_POINT()

	function is_packet_break()
	
		NPOINTS_SENT_EX = NPOINTS_SENT * SD.NPOINTS_PER_SAMPLE
		PACKET_NUMBER = math.floor(NPOINTS_SENT_EX / SD.NPOINTS_PER_PACKET)

		return (NPOINTS_SENT_EX < SD.NPOINTS_EXPECTED) and
			( (NPOINTS_SENT_EX - PACKET_NUMBER * SD.NPOINTS_PER_PACKET) < SD.NPOINTS_PER_SAMPLE )
	end

	NPOINTS_SENT = NPOINTS_SENT + 1;

	if NULLING_MASK > 0 then
		SET(0xf9, 0x00)
	end
	
	SET(0xFE)
	
	if is_packet_break() then
		SET(0x89)
		SET(0x00)
	end

end

function TRANSMIT_ON_NEXT_MS() 
	if (#SL > 1) then 
	SET(0xFC) 
		DELAY(1)
	end
end

function SEND_SWEEP_TIMER()
	SET(0x87, 0x10)
	SET(0xFE) 
end

function DELAY(n) 
	for i = 1, n do
		SET(0xFD) 
	end
end

-- helper function
function frequency_multiplier()
	local band = GET_BAND_TYPE()
	if band == FREQ_BAND_1 then
		return 0x2000
	elseif band == FREQ_BAND_2 then
		return 0x1000
	elseif band == FREQ_BAND_3 then
		return 0x0800
	else
		error("invalid frequency band type")
	end
end

RX_OFFSET_BAND_0 = 0x15668
RX_OFFSET_BAND_1 = 0xab34
RX_OFFSET_BAND_2 = 0x559a

-- helper function
function frequency_offset(isTX)
	if (isTX) then
		return 0
	end
	
	local band = GET_BAND_TYPE()
	local offset = 0
	
	if band == FREQ_BAND_1 then
		offset = RX_OFFSET_BAND_0
	elseif band == FREQ_BAND_2 then
		offset = RX_OFFSET_BAND_1
	elseif band == FREQ_BAND_3 then
		offset = RX_OFFSET_BAND_2
	else
		error("invalid frequency band type")
	end
	
	return IS_LOWER_ANTENNA() and -offset or offset
end

function restrict(f)
	if IS_LOWER_ANTENNA() then
		if IS_LOW_SIDE_LO() then
			return f + LOW_SIDE_LO
		else
			return HIGH_SIDE_LO - f
		end
	end
	return f
end

function CalculateFrequencyFactor(f)

	function FindTableEntry(f)
		i = 1
		while f > PLLTable[i][1] do
			i = i + 1
		end
		return PLLTable[i]
	end
		
	if HP.PLL_USE_TABLE then
		e = FindTableEntry(f)
		if prev_e ~= e then
			SET(0x9D, 0x02)
			SET(0xB4, e[2])
			SET(0x84, 0x01)
			DELAY(1);
		end
		prev_e = e
		return 50.0 / e[2]
	else
		return 50.0 / HP.PLL_DIVIDER
	end
end

function TX_FREQUENCY(f)
	f = restrict(f)
	
	i = f * frequency_multiplier()
	j = i + frequency_offset(true)
	
	freqFactor = CalculateFrequencyFactor(f)

	j = j * freqFactor
	
	SET(0x06, _AND(j, 0x00ff))
	SET(0x05, _AND(_SR(j,  8), 0x00ff))
	SET(0x04, _AND(_SR(j, 16), 0x00ff))
end

function RX_FREQUENCY(f)
	f = restrict(f)

	i = f * frequency_multiplier()
	j = i + frequency_offset(false)

	freqFactor = CalculateFrequencyFactor(f)

	j = j * freqFactor
	
	SET(0x46, _AND(j, 0x00ff))
	SET(0x45, _AND(_SR(j,  8), 0x00ff))
	SET(0x44, _AND(_SR(j, 16), 0x00ff))
end

function SEND_MS_CLOCK()
	SET(0x8f, 0x20)
end


function RECEIVE_MS_CLOCK()
	SET(0x8f, 0x10)
end

function SET_MS_CLOCK_STATUS(sensorIndex)

	sensorType = SL[sensorIndex].TYPE
	
	if sensorType == ARRAY_MASTER or sensorType == MASTER_SLAVE then
		SEND_MS_CLOCK()
	end
	
	if 
		sensorType == ARRAY_SLAVE or
		sensorType == PSEUDO_MASTER or
		sensorType == PSEUDO_SLAVE 
	then
		RECEIVE_MS_CLOCK()
	end
	
end

function SET_FREQ_OFFSET_VALUES(sensorIndex)
	if SL[sensorIndex].TYPE == PSEUDO_MASTER then
		SET(0x36, HP.FREQ_OFFSET_VALUE)
		if HP.FREQ_OFFSET then
			SET(0x37, 0x03)
		else
			SET(0x37, 0x05)
		end
	end
end

---------------------------------------------------------------------
-- Even though this is called from C++, it does not often need to be 
-- changed and is included here, in the library.
---------------------------------------------------------------------
function BuildPowerUpSequence(sensorIndex)

	print("BuildPowerUpSequence", sensorIndex)

	local sensor = SL[sensorIndex]
	local is_active = 
			sensor.TX or sensor.RX or 
			sensor.TYPE == ARRAY_MASTER or
			sensor.TYPE == PSEUDO_MASTER

	SET_POWER_ON_ADDRESS(0x0000);
	SET_PC(0x0000)
	
	SET_BAND_TYPE(FREQ_BAND_2)
	--if is_active then
		if sensor.TYPE == PSEUDO_MASTER then SET(0x9e, 0x80) end
		POWER_UP()
		SET_MS_CLOCK_STATUS(sensorIndex)
		RESET_FRAME_COUNTER()
		SET_GATE_VALUES()
		BUILD_STARTUP_SEQUENCE(sensorIndex)
		SET_FREQ_OFFSET_VALUES(sensorIndex)
		SET_ATTENUATION_VALUES()
		DELAY(1)
	--else
	--	POWER_DOWN()
	--end
	STOP()
end

---------------------------------------------------------------------
function BuildSignatureSequence()
	SET_PC(0x0100)
	SET(0x53)
	SET(0x41)
	SET(0x54)
	SET(0x41)
	SET(0x4e)
	STOP()
end

---------------------------------------------------------------------
-- User needs to define this function is a separate file
-- that "includes" this one.
---------------------------------------------------------------------
function BuildSweepMacro(sensorIndex, entry)
	error("BuildSweepMacro needs to be implemented")
end

---------------------------------------------------------------------
function Port2Antenna(port)

	if (port == 0) then
		return 0
	else
		index2antenna = {0, 4, 2, 6, 1, 5, 3, 7}
		return index2antenna[port];
	end
end

---------------------------------------------------------------------
function SET_GATE_CONTROL(sensorType, isMono)
	local gateMask = 0x00;

	if PP.ENABLE_GATE_VALUES then
		gateMask = _OR(gateMask, 0x01)
	end

	if NULLING_MASK > 0 then
		gateMask = _OR(gateMask, 0x02)
	end

	if 
		sensorType == MASTER_SLAVE or
		sensorType == ARRAY_SLAVE or
		sensorType == PSEUDO_SLAVE 
	then
		gateMask = _OR(gateMask, 0x04)
	end

	if HP.POWER_AMP then
		gateMask = _OR(gateMask, 0x08)
	end

	if HP.LNA then
		gateMask = _OR(gateMask, 0x10)
	end

	if HP.POWER_AMP_ATTEN then
		gateMask = _OR(gateMask, 0x20)
	end

	if isMono then
		gateMask = _OR(gateMask, 0x40)
	end

	SET(0x97, 0x00)
	SET(0x98, gateMask)
end

---------------------------------------------------------------------
function NS2Clock(NS)

	--Based upon 163.84 MHz clock.
	--ns per clock-cycle
	GATE_CONVERSION_FACTOR = 6.1035;  
	
	return NS / GATE_CONVERSION_FACTOR;
end


---------------------------------------------------------------------
function SET_GATE_VALUES()
	if PP.ENABLE_GATE_VALUES then
		SET(0x97); SET(0x1); SET(0x98); SET(NS2Clock(PP.GATE_TX1))
		SET(0x97); SET(0x2); SET(0x98); SET(NS2Clock(PP.GATE_TX1_RX1))
		SET(0x97); SET(0x3); SET(0x98); SET(NS2Clock(PP.GATE_RX1))
		SET(0x97); SET(0x4); SET(0x98); SET(NS2Clock(PP.GATE_RX1_RX2))
		SET(0x97); SET(0x5); SET(0x98); SET(NS2Clock(PP.GATE_RX2))
		SET(0x97); SET(0x6); SET(0x98); SET(NS2Clock(PP.GATE_RX2_TX1))
	end
end

---------------------------------------------------------------------
function SET_ATTENUATION_VALUES()
	if (HP.POWER_AMP_ATTEN) then
		SET(0x97); SET(0x7); SET(0x98); SET(HP.POWER_AMP_ATTEN_VALUE)
	end
end

---------------------------------------------------------------------
function BuildJumpTable(radar, entry)

	radarList = config.get_radar_table()
	sensorType = radarList[radar].TYPE

	print("----------------------------------------------------------------------")
	print("radar: ", radar, "sensorType:", sensorType)
	print("----------------------------------------------------------------------")
	
	function SET_ANTENNA(SEX)

		if sensorType == ARRAY_MASTER then
			SET(0x82, 0x01)
			return
		end

		local antennaMask = 0x00

		if sensorType == PSEUDO_MASTER then
			-- Treat it like a slave, but transmitting, unconditionally.
			antennaMask = 0x01;
		end

		if sensorType == ARRAY_SLAVE or sensorType == PSEUDO_SLAVE or sensorType == MASTER_SLAVE then
			-- Treat it like a slave, but transmitting, unconditionally.
			antennaMask = SEX.IS_TX and 0x01 or 0x80
			end
			
		local TX = SEX.TX
		local RX = SEX.RX

		-- ports
		local TXport, RXport

			if IS_SWITCHED() then
				TXport = TX > 0 and SL[TX].PORT or 0
				RXport = RX > 0 and SL[RX].PORT or 0
			else			
				TXport = TX > 0 and SL[TX].TX_PORT or 0
				RXport = RX > 0 and SL[RX].RX_PORT or 0
			end
			
		-- antennas

		local TA = TXport > 0 and Port2Antenna(TXport) or 0
		local RA = RXport > 0 and Port2Antenna(RXport) or 0
			
			antennaMask = _OR(antennaMask, _SL(TA, 4))
			antennaMask = _OR(antennaMask, _SL(RA, 0))


			print(string.format("TX: %d  RX: %d  TXport: %d  RXport %d  antennaMask = 0x%.2x  isTX = %s", 
				TX, RX, TXport, RXport, antennaMask, tostring(SEX.IS_TX)))

		SET(0x82, antennaMask)
	end


	function SET_PORT_ASSIGNMENTS(sensorIndex)

		setTX = IS_TX_ALTERNATED()
		setRX = IS_RX_ALTERNATED()
		setTXRX = IS_TXRX_ALTERNATED()
		
		portMask = 0x00
		
		portMask = _OR(portMask, setTX and 0x02 or 0x00)
		portMask = _OR(portMask, setRX and 0x01 or 0x00)
		portMask = _OR(portMask, setTXRX and 0x04 or 0x00)
		
		if (SL[sensorIndex].VERSION >= 0x43) then
			SET(0x9b, portMask) 
		end

		--print(string.format("portMask: %x", portMask))
	end
	
	function SET_NULLING_ADDRESS(sweepIndex)
		if NULLING_MASK > 0 then
			SET(0x9f, GET_NULLING_OFFSET(sweepIndex))
		end
	end

	callAddress = entry

	SET_PC(entry)
	for sweep = 1, #SX do
		SEX = SX[sweep][radar]
		--if SEX.IS_ACTIVE then
			SET_NULLING_ADDRESS(sweep)
			SET_GAIN(radar)
			SET_ANTENNA(SEX)
			SET_PORT_ASSIGNMENTS(SEX.TX)
			SET_GATE_CONTROL(sensorType, SEX.IS_TX and SEX.TX == SEX.RX)
			SET_ENCODER_CONTROL()
			CALL_ABSOLUTE(entry + SWEEP_MACRO_OFFSET)
		--end
	end
	JUMP_ABSOLUTE(entry)
end

