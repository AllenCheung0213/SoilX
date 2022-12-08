L = require("UTIL-Lua")
P = require("UTIL-Plot")

--------------------------------------------------------
CV = complex_vector
 V = vector

CM = complex_matrix

-- SOURCE_NAME is bound to the analysis window
-- that called this script. We can access the window
-- and its contents using it.

if SOURCE_NAME == "" then
	window_manager.unregister(SOURCE_NAME, PROGRAM_NAME)
	forms.error("Not a stand-alone script. Must be run from an Analysis Window")
end

analysis_type = chart.get_analysis_type(SOURCE_NAME)
if analysis_type ~= MAGNITUDE_VS_TIME and analysis_type ~= MAGNITUDE_VS_DISTANCE then
	window_manager.unregister(SOURCE_NAME, PROGRAM_NAME)
	forms.error("Not a valid analysis type. Select either Time or Distance from View Menu.")
end

SP = chart.get_scan_parameter_table(SOURCE_NAME)
AP = chart.get_analysis_parameter_table(SOURCE_NAME)

--L.display("SP", SP)
--L.display("AP", AP)

function Process()
-- This script is only valid in the time and distance domains.
--------------------------------------------------------------
x0, x1 = chart.get_scale(SOURCE_NAME)

-- Convert meters to nano-seconds.
if analysis_type == MAGNITUDE_VS_DISTANCE then
	x0 = x0 / 0.15
	x1 = x1 / 0.15
end
--print(x0, x1)

-- Get the raw complex freq domain data.
------------------------------------------------------------------------
cm = chart.get_matrix(SOURCE_NAME)

-- The selection vector contains ones and zeroes denoting
-- lines that are visible in the source window.
sv = chart.get_selection_vector(SOURCE_NAME)

-- Reduce the matrix to only selected rows.
------------------------------------------------------------------------
cs = CM.select(cm, sv)


-- We will need to know where to get titles for the selected vectors.
-- Convert the selection vector into an index vector by selecting from
-- a vector of indexes.
iv = V.select(V(#cm, 1, 1), sv)

-- Might as well get the line attributes now.
T1 = {}
T2 = {}
DT = {}
for i = 1, #iv do
	T1[i] = chart.get_title1(SOURCE_NAME, iv[i])
	T2[i] = chart.get_title2(SOURCE_NAME, iv[i])
	DT[i] = chart.get_delay(SOURCE_NAME, iv[i])
end


-----------------------------------------
-- Convert everything to the time domain.
-----------------------------------------
ct = CM.fft( cs, AP.FFT_SIZE, SP.START_FREQ, SP.STOP_FREQ, AP.WINDOW_FFT, true  )
--print(cs, AP.FFT_SIZE, SP.START_FREQ, SP.STOP_FREQ, AP.WINDOW_FFT, true  )

-- We need these for scaling purposes.
------------------------------------------------------------------------
dF = data_source.get_freq_step(SP.SCAN_SIZE, SP.START_FREQ, SP.STOP_FREQ)
dT = data_source.get_time_step(AP.FFT_SIZE, SP.SCAN_SIZE, SP.START_FREQ, SP.STOP_FREQ)
--print(dF, dT)

-- Calculate the indexes of the bounding window.
------------------------------------------------------------------------
I0 = x0 / dT
I1 = x1 / dT

--I0 = math.max(0, I0)
--I1 = math.min(SP.SCAN_SIZE, I1)

-- Need to know 1/2 the width of the window.
dI = (I1 - I0) / 2

--print("I0, I1, dI (unadjusted) = ", I0, I1, dI)

-- Now, for each vector in the time domain, set the outside points to zero.
---------------------------------------------------------------------------
for i = 1, #ct do

	-- Find the location of the peak within the bounding window.
	local vmax, imax = V.max( V.slice( CV.abs(ct[i]), I0, I1 ) )
	imax = imax + I0
	
	--print(vmax, imax)

	-- Adjust I0, I1 w.r.t peak location.
	local J0 = imax - dI
	local J1 = imax + dI

	J0 = math.max(0, J0)
	J1 = math.min(AP.FFT_SIZE, J1)

	--print("J0, J1 (adjusted) = ", J0, J1)

	-- I is a vector of indexes {1 .. nFFT]
	local I = V(AP.FFT_SIZE, 1, 1)

	-- Reduce I to the indexes outside the boundng window.
	I = V.find(I, function(x) return x < J0 or x > J1 end)

	-- Now, set the outside points to zero.
	local temp = ct[i] ; temp[I] = 0 ; ct[i] = temp
end

---------------------------------------------------
-- Convert everything back to the frequency domain.
---------------------------------------------------
cf = CM.fft( ct, AP.FFT_SIZE, false, false )
--cf = CM.reverse(cf)

-- Need to strip out the zeroes in the first FFT,
-- We want to keep everything in the interval [z0..z1].
z0 = math.floor(SP.START_FREQ / dF);
z1 = z0 + SP.SCAN_SIZE - 1;

-- Cf should be reduced back to the original SCAN_SIZE.
cf = CM.slice2(cf, z0, z1)


-- By spawning from the source, we get a new window with all
-- the original window properties, unless SOURCE_NAME-P3 already exists.
------------------------------------------------------------
w = chart.spawn(SOURCE_NAME, "01")
window_manager.register(SOURCE_NAME, PROGRAM_NAME, w)

sel = chart.get_selection_vector(w)

chart.clear(w)
for i = 1, #cf do
	chart.add(w, cf[i], T1[i], T2[i], DT[i])
end
--chart.reset_scale(w)
chart.set_analysis_type(w, MAGNITUDE_VS_FREQUENCY)
AP.WINDOW_FFT = false ; 
chart.set_analysis_parameter_table(w, AP)
chart.set_option(w, DB_FREQ, false);
if #sel > 0 and #sel == #cf then
	chart.set_selection_vector(w, sel)
end
chart.update(w)
end