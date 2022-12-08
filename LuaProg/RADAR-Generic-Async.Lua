--
-- RADAR-Generic-Async.lua
--

dofile("LuaProg/RADAR-Library-Async.lua")

function ProcessSweepPoint()
	local is_currently_active = true
	return
		function (is_active)
			if is_active then
				if is_currently_active == false then
					POWER_UP(true)
					DELAY(1)
					is_currently_active = true
				end
				SEND_SWEEP_POINT()
			else
				if is_currently_active == true then
					POWER_UP(false)
					DELAY(1)
					is_currently_active = false
				end
				if HP.SEND_EXCLUDED_POINT then
					SEND_SWEEP_POINT()
				end
			end
		end
end

ProcessSweepPoint = ProcessSweepPoint()

---------------------------------------------------------------------
-- Called from C++
---------------------------------------------------------------------
function BuildSweepMacro(sensorIndex, entry)

	print(string.format("BuildSweepMacro %d 0x%x", sensorIndex, entry))
	
	SET_SWEEP_ADDR(entry)
	
	BuildJumpTable(sensorIndex, entry)
		
	local f0 = SD.MAP[1].FREQ
	
	-- Sweep Macro Body
	BEGIN_SWEEP_MACRO()
	SET_PC(entry + SWEEP_MACRO_OFFSET)
	
	SET_ANTENNA_TYPE(f0)
	SET_BAND_TYPE(f0)
	
	TX_FREQUENCY(f0)
	SET(0x20, 0x40)
	RX_FREQUENCY(f0)
	POWER_UP()
	DELAY(1)
	TRANSMIT_ON_NEXT_MS()
	SEND_SWEEP_TIMER()
	ProcessSweepPoint(SD.MAP[1].STATUS == 1)
	
	for i = 2, #SD.MAP do
		f = SD.MAP[i].FREQ
		
		if SD.MAP[i].TRANS == 1 then
			SET_BAND_TYPE(f)
			if IS_ANTENNA_TRANSITION(f) then
				SET_ANTENNA_TYPE(f)
			end
			
			TX_FREQUENCY(f)
			RX_FREQUENCY(f)
			POWER_UP()
			DELAY(4)
		else
			TX_FREQUENCY(f)
			RX_FREQUENCY(f)
		end
		ProcessSweepPoint(SD.MAP[i].STATUS == 1)
	end
	
	-- send packet
	SET(0x89, 0x01)		
	DELAY(1)

	-- jump back to entry
	RETURN()
	STOP()
end
