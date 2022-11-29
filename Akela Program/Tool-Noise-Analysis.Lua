-----------------------------------------------------------------------------------------
-- Title: Noise Analysis
-- Description: 
--	Perform user specified noise analyses on the current open data file
-- Author: Patton Gregg
-- Revision History:
--	1.32, 04/11/2011
--		Refactored code to make things cleaners
--		Fixed bug in plotting magnitude of standard deviation
--	1.31, 04/11/2011
--		Fixed bug where the surface plots were transposed from their correct orientation
--	1.30, 11/30/2010
--		Fixed x-axis label for scalar plot of Time domain MAG(STD) analysis from frequencies to times
--		General clean up of code
--	1.20, 01/07/2009
--		Initial Release

-----------------------------------------------------------------------------------------

dofile("LuaProg/Lib-Header.lua")
dofile("LuaProg/Lib-File.lua")
dofile("LuaProg/Lib-Math.lua")
dofile("LuaProg/Tool-Noise-Plot.lua")

-----------------------------------------------------------
-- Verify parameters and filter tape
-----------------------------------------------------------
function verify(params)
	
	tape = DS.get_tape()
	
	if #tape == 0 then
		forms.message("Please Specify a Noise Data File")
		tape = data_tape.open()
	end
	
	filename = string.gsub(DT.get_filename(tape), ".+[/\\]", "")
	full_filename = data_tape.get_filename(tape)
	
	if data_tape.is_valid_combination(tape, params.tx+1, params.rx+1) == false then
		forms.error("Tx/Rx Combination Not Valid!")
		return false
	end
	
	tape = tape[function (x) return x.TX == params.tx+1 and x.RX == params.rx+1 end]
	nScansData = #tape

	if params.scan_start >= #tape then
			forms.error("Starting scan number greater than the number of valid scans (Total No. Scans = " .. #tape .. ")!")
			return false
	else
		-- Get rid of all the scans before user specified starting scan number
		tape = data_tape.slice(tape, params.scan_start)
	end
	
	-- If the user wants to limit the number of scans, then only that number of scans is retained
	if params.limit_scans then
		tape = data_tape.truncate(tape, params.scan_num)
	end

	NS = #tape
	
	if params.scan_win >= NS then
		forms.error("The total number of scans is less than or equal to the STD group size! (Max Size is " .. NS-1 .. ")")
		return false
	end
	
	if params.limit_scans and params.scan_num > NS then
		forms.warning("Max. number of scans greater than the total number of scans!")
	end
	
	if params.scan_win < 0 then 
		forms.error("StdDev Group Size Less Than 0!"); 
		return false 
	end
	if params.freq_dom == false and params.time_dom == false then
		forms.error("No Domain Specified!")
		return false 
	end
	if params.mag_sd == false and params.sd_mag == false and params.sd_phase == false and params.sd_i == false and params.sd_q == false then
		forms.error("No Analysis Specified!")
		return false 
	end
	return true
end

dofile("LuaProg/Tool-Noise-Dialog.lua")

params = get_parameters()
if params == nil then error() end

print("Number of Scans in Data File: ", nScansData)

---------------------------------------------------------
-- Functions
---------------------------------------------------------

-- Standard Deviation Function
function stdev(VALUES, groupsize)

	X1 = M.cumsum( VALUES )
	X2 = M.cumsum( VALUES^2 )

	v1 = V(NS - groupsize, 1, 1)
	v2 = V(NS - groupsize, groupsize + 1, 1)

	A1 = X1[v2] - X1[v1]; A1 = A1 / groupsize
	A2 = X2[v2] - X2[v1]; A2 = A2 / groupsize

	A = M.sqrt(M.abs(A2 - A1^2))
	A = M.transpose(A)

	return A
end

function GetMagSTD (values_real, values_imag, groupSize)
	local M_real_sd_scal = stdev(values_real, groupSize)
	local M_imag_sd_scal = stdev(values_imag, groupSize)
	local XX_mag_sd_scal = V.sqrt(M_real_sd_scal[1]^2+M_imag_sd_scal[1]^2)
	XX_mag_sd_scal = 20 * V.log10(XX_mag_sd_scal)
	
	return XX_mag_sd_scal
end

-- Performs the STD and plots for all analyses EXCEPT MAG(STD)
function run_analysis(SCAN_MATRIX, analysis, x_pts, x_label, time_dom)

	-- For plotting a histogram of image simply pass the standard deviation of the scan matrix
	if params.plot_hist or params.plot_image then
		NOISE_MATRIX = stdev(SCAN_MATRIX, params.scan_win)
	
		if params.plot_hist then
			hist, savename = plot_histogram(NOISE_MATRIX, analysis, time_dom)
			if params.file_out then	chart.write(hist, savename) end
		end
		if params.plot_image then
			plot_image(NOISE_MATRIX, tape, analysis, time_dom)
			if params.file_out then	chart.write(p, savename) end
		end
	end
	-- For plotting a scalar chart convert the standard deviation to dB
	if params.plot_scalar then
		stdevScanMatrix = stdev(SCAN_MATRIX, NS-1)
		NOISE_VECTOR = 20 * V.log10(stdevScanMatrix[1])
		W1, savename = plot_chart(analysis, x_pts, NOISE_VECTOR, x_label, time_dom)
		if params.file_out then chart.write(W1, savename) end
	end
end

function choose_analysis (data, data_fft, param, analysis)
	
	-- Checks if user hit cancel
	if param then
		if params.freq_dom then
			run_analysis(data, analysis, freqs, label_freq, false)
		end
		if params.time_dom then
			run_analysis(data_fft, analysis, times, label_time, true)
		end
	end
end

--------------------------------------------------------
-- Setup Variable Values
----------------------------------------------------------

-- GET no-data-points, start- and stop-frequency,
-- and scan-rate which will be converted to
-- a time-step.
NF, F0, F1, SR = DT.get_scan_parameters(tape)
print("NF, F0, F1, SR", NF, F0, F1, SR)

freq_step = DT.get_freq_step(tape, NF, F0, F1)
time_step = ( (1*10^3) / (freq_step) ) / NF

freqs = V(NF, F0, freq_step)
times = V(NF, 0, time_step)
time_end = (1*10^3) / (freq_step)

label_time = "Time (ns)"
label_freq = "Frequency (MHz)"

fname_no_ext, ext = ChopExtension(filename)

------------------------------------------------------------
-- Analysis Stuff
------------------------------------------------------------

freqData = data_tape.get_matrix(tape)

nFFT = Order2N(N2Order(2 * (F1 / freq_step)))
print("nFFT", nFFT)

if params.time_dom then
	timeData = CM.fft(freqData, nFFT, F0, F1, params.windowing, true)
	timeData = CM.transpose(timeData)
end 

freqData = CM.transpose(freqData)

print("Number of Scans Used: " .. NS)

if params.freq_dom then

	-- stddev(mag)
	if params.sd_mag then
		XX_sd_mag = CM.abs(freqData)
	end
	-- stddev(phase)
	if params.sd_phase then
		XX_sd_phase = CM.unwrap(freqData)
	end
	-- stddev(i)
	if params.sd_i or params.mag_sd then
		XX_sd_i = CM.real(freqData)
	end
	-- stddev(q)
	if params.sd_q or params.mag_sd then
		XX_sd_q = CM.imag(freqData)
	end

	-- mag(stddev)
	if params.mag_sd then
		local M_real_sd = M()
		local M_imag_sd = M()
		
		-- For plotting a histogram of image simply pass the standard deviation of the scan matrix
		if params.plot_hist or params.plot_image then
			M_real_sd = stdev(XX_sd_i, params.scan_win)
			M_imag_sd = stdev(XX_sd_q, params.scan_win)
			XX_mag_sd = M.sqrt(M_real_sd^2 + M_imag_sd^2)
			
			if params.plot_hist then
				hist, savename = plot_histogram(XX_mag_sd, "MAG(STD)", false)
				if params.file_out then	chart.write(hist, savename) end
			end
			if params.plot_image then
				plot_image(XX_mag_sd, tape, "MAG(STD)", false)
				if params.file_out then	chart.write(p, savename) end
			end
		end
		
		-- For plotting a scalar chart convert the standard deviation to dB
		if params.plot_scalar then
			XX_mag_sd_scal = GetMagSTD(XX_sd_i, XX_sd_q, NS-1)
			
			W1, savename = plot_chart("MAG(STD)", freqs, XX_mag_sd_scal, label_freq, false)
			if params.file_out then chart.write(W1, savename) end
		end
	end
end

if params.time_dom then

	--stddev(mag)
	if params.sd_mag then
		XX_sd_mag_fft = CM.abs(timeData)
	end
	--stddev(phase)
	if params.sd_phase then
		XX_sd_phase_fft = CM.unwrap(timeData)
	end
	-- stddev(i)
	if params.sd_i or params.mag_sd then
		XX_sd_i_fft = CM.real(timeData)
	end
	-- stddev(q)
	if params.sd_q or params.mag_sd then
		XX_sd_q_fft = CM.imag(timeData)
	end

	-- mag(stddev)
	if params.mag_sd then
		local M_real_sd_fft = M()
		local M_imag_sd_fft = M()
	
		-- For plotting a histogram of image simply pass the standard deviation of the scan matrix
		if params.plot_hist or params.plot_image then
			
			M_real_sd_fft = stdev(XX_sd_i_fft, params.scan_win)
			M_imag_sd_fft = stdev(XX_sd_q_fft, params.scan_win)
			local XX_mag_sd_fft = M.sqrt(M_real_sd_fft^2 + M_imag_sd_fft^2)
			
			if params.plot_hist then
				hist, savename = plot_histogram(XX_mag_sd_fft, "MAG(STD)", true)
				if params.file_out then	chart.write(hist, savename) end
			end
			
			if params.plot_image then
				p, savename = plot_image(XX_mag_sd_fft, tape, "MAG(STD)", true)
				if params.file_out then	chart.write(p, savename) end
			end
		end
		
		-- For plotting a scalar chart convert the standard deviation to dB
		if params.plot_scalar then
			local XX_mag_sd_scal_fft = GetMagSTD(XX_sd_i_fft, XX_sd_q_fft, NS-1)
			
			W1, savename = plot_chart("MAG(STD)", times, XX_mag_sd_scal_fft, label_time, true)
			if params.file_out then chart.write(W1, savename) end
		end
	end
	
end

---------------------------------------------------------
choose_analysis(XX_sd_mag, XX_sd_mag_fft, params.sd_mag, "STD(MAG)")
choose_analysis(XX_sd_phase, XX_sd_phase_fft, params.sd_phase, "STD(PHASE)")
choose_analysis(XX_sd_i, XX_sd_i_fft, params.sd_i, "STD(i)")
choose_analysis(XX_sd_q, XX_sd_q_fft, params.sd_q, "STD(q)")