-- Fixes problem with band transition without sweep point!

--
-- RADAR-Generic-00.lua
--

dofile("LuaProg/RADAR-Library.lua")


---------------------------------------------------------------------
-- Called from C++
---------------------------------------------------------------------
function BuildSweepMacro(sensorIndex, entry)

	print("BuildSweepMacro", sensorIndex, entry)
	
	version = GET_VERSION(sensorIndex)

	SET_SWEEP_ADDR(entry)
	
	if IS_SWITCHED() then
		BuildJumpTablelSwitched(sensorIndex, entry)
	else
		BuildJumpTablelDistributed(sensorIndex, entry)
	end
		
	f0 = SD.MAP[1].FREQ
	
	-- Sweep Macro Body
	BEGIN_SWEEP_MACRO()
	SET_PC(entry + 0x100)
	
	BUILD_STARTUP_SEQUENCE()
	SET_BAND_TYPE(f0)
	
	TX_FREQUENCY(f0)
	--POWER_DOWN()
	--SET_TX_MULT(version)
	--SET(0x1F, 0x00)
	SET(0x20, 0x40)
	RX_FREQUENCY(f0)
	--~SET(0x5D, 0x00)
	--~SET_RX_MULT(version)
	--~SET(0x5F, 0x00)
	--~SET(0x60, 0x40)
	POWER_UP()
	DELAY(11)
	TRANSMIT_ON_NEXT_MS()
	DELAY(9)
	SEND_SWEEP_TIMER()
	SEND_SWEEP_POINT()

	for k = 2, #SD.MAP do
	
		f = SD.MAP[k].FREQ
		
		if SD.MAP[k].STATUS == 1 then

			if SD.MAP[k].TRANS == 1 then
				TOGGLE_BAND_TYPE()
				TX_FREQUENCY(f0)
				RX_FREQUENCY(f0)
				POWER_UP()
				DELAY(2)
			else
				TX_FREQUENCY(f0)
				RX_FREQUENCY(f0)
			end
			SEND_SWEEP_POINT()

		end
	end
	POWER_DOWN()
	DELAY(1)
	STOP()
end

