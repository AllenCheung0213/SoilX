L = require("Util-Lua")

local params = {}
local PARAMS_FILE = "LuaProg/Tool-Data-Proc-Parameters.lua"

----------------------------------------------------------
----------------------------------------------------------
function edit_parameters()
	
	d = dialog("Data Processing Tools - " .. VERSION, 520, 610, 220, 30)
	
	dialog.set_help(d, "Documentation/Data Processing Tools - Help.pdf");
	
	dialog.begin_tab(d, "Input Files")
	
	dialog.control(d, "PROCESS DIRECTORY OF FILES", BOX, FL_NO_BOX)
	dialog.control(d, "Process Directory of Files", CHECKBOX, "proc_file_dir", params.proc_file_dir)
	dialog.control(d, "Directory", DIR, "file_dir", params.file_dir)
	dialog.control(d, "PROCESS SPECIFIC FILES", BOX, FL_NO_BOX)
	dialog.control(d, "Process File 1", CHECKBOX, "proc_file1", params.proc_file1)
	dialog.control(d, "Data File 1", FILE, "file1", params.file1)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Process File 2", CHECKBOX, "proc_file2", params.proc_file2)
	dialog.control(d, "Data File 2", FILE, "file2", params.file2)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Process File 3", CHECKBOX, "proc_file3", params.proc_file3)
	dialog.control(d, "Data File 3", FILE, "file3", params.file3)
	dialog.control(d, "OUTPUT DIRECTORY", BOX, FL_NO_BOX)
	dialog.control(d, "Use Alternate Output Directory", CHECKBOX, "out_alt", params.out_alt)
	dialog.control(d, "Output Directory", DIR, "out_alt_dir", params.out_alt_dir)
	
	dialog.end_tab(d)

	dialog.begin_tab(d, "Filter")

	dialog.control(d, "Normalize Data", CHECKBOX, "norm", params.norm)
	dialog.control(d, "Normalization File", FILE, "norm_file", params.norm_file)
	dialog.control(d, "Normalization Frame Number", INTEGER, "norm_scan", params.norm_scan)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Scale Data", CHECKBOX, "scale", params.scale)
	dialog.control(d, "Scale Factor", NUMBER, "scale_factor", params.scale_factor)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Time Window Data", CHECKBOX, "tw", params.tw)
	dialog.control(d, "Time Window - Start (nsec)", NUMBER, "tw_start", params.tw_start)
	dialog.control(d, "Time Window - Stop (nsec)", NUMBER, "tw_stop", params.tw_stop)
	dialog.control(d, "Apply Hanning Window", CHECKBOX, "tw_hanning", params.tw_hanning)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Subtract Data", CHECKBOX, "bg_sub", params.bg_sub)
	dialog.control(d, "Data File to Subtract", FILE, "bg_file", params.bg_file)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Subtract Running Average", CHECKBOX, "sub_run_avg", params.sub_run_avg)
	dialog.control(d, "No Scans", INTEGER, "sub_run_avg_nscans", params.sub_run_avg_nscans)
	
	dialog.end_tab(d)
	
	dialog.begin_tab(d, "Analysis")

	dialog.control(d, "Average Frames", CHECKBOX, "avg_frames", params.avg_frames)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Min/Max Frequency Trace", CHECKBOX, "min_max_freq", params.min_max_freq)
	dialog.control(d, "Min/Max Distance Trace", CHECKBOX, "min_max_dist", params.min_max_dist)
	dialog.control(d, "Min/Max Time Trace", CHECKBOX, "min_max_time", params.min_max_time)
	dialog.control(d, "Min/Max Settings", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Plot Time/Dist in Log Scale", CHECKBOX, "min_max_time_db", params.min_max_time_db)
	dialog.control(d, "Distance Correction", NUMBER, "min_max_dist_corr", params.min_max_dist_corr)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Find Signal-to-Noise Ratio", CHECKBOX, "snr", params.snr)
	dialog.control(d, "Target Signal Range (m)", NUMBER, "snr_target_dist", params.snr_target_dist)
	dialog.control(d, "Noise Signal Range (m)", NUMBER, "snr_noise_dist", params.snr_noise_dist)
	
	dialog.end_tab(d)

	dialog.begin_tab(d, "Edit I")

	dialog.control(d, "Output Frame Clip ", CHECKBOX, "clip1", params.clip1)
	dialog.control(d, "Frame Start", INTEGER, "clip1_start", params.clip1_start)
	dialog.control(d, "Frame Stop", INTEGER, "clip1_stop", params.clip1_stop)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Output Clip of Last N Frames", CHECKBOX, "clipN", params.clipN)
	dialog.control(d, "No. Frames to Clip from End", INTEGER, "clipN_nFrames", params.clipN_nFrames)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Output Time Clip", CHECKBOX, "clipTS", params.clipTS)
	dialog.control(d, "Timestamp Start", INTEGER, "clipTS_start", params.clipTS_start)
	dialog.control(d, "Timestamp Stop", INTEGER, "clipTS_stop", params.clipTS_stop)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Output Clip of Last N Seconds", CHECKBOX, "clipTSN", params.clipTSN)
	dialog.control(d, "No. Seconds to Clip from End", INTEGER, "clipTSNSeconds", params.clipTSNSeconds)
	
	dialog.end_tab(d)
	
	dialog.begin_tab(d, "Edit II")

	dialog.control(d, "Output Frequency Band", CHECKBOX, "freq_range1", params.freq_range1)
	dialog.control(d, "Start Frequency (MHz)", NUMBER, "freq_range_start1", params.freq_range_start1)
	dialog.control(d, "Stop Frequency (MHz)", NUMBER, "freq_range_stop1", params.freq_range_stop1)
	dialog.control(d, "Exclude Points in Band", CHECKBOX, "freq_range_ex", params.freq_range_ex)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Correct GPS UTM Coordinates", CHECKBOX, "utm_correct", params.utm_correct)
	dialog.control(d, "UTM Easting Offset (m)", NUMBER, "utm_easting_off", params.utm_easting_off)
	dialog.control(d, "UTM Northing Offset (m)", NUMBER, "utm_northing_off", params.utm_northing_off)

	dialog.end_tab(d)

	dialog.begin_tab(d, "Extract I")

	dialog.control(d, "Output Position Data", CHECKBOX, "pos_data", params.pos_data)
	dialog.control(d, "GPS", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Extract GPS 1 Data", CHECKBOX, "gps_sensor1", params.gps_sensor1)
	dialog.control(d, "GPS Sensor 1 Number", INTEGER, "gps_sensor_num1", params.gps_sensor_num1)
	dialog.control(d, "Extract GPS 2 Data", CHECKBOX, "gps_sensor2", params.gps_sensor2)
	dialog.control(d, "GPS 2 Sensor Number", INTEGER, "gps_sensor_num2", params.gps_sensor_num2)
	dialog.control(d, "ENCODERS", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Extract Encoder 1 Data", CHECKBOX, "enc1_extract", params.enc1_extract)	
	dialog.control(d, "Encoder 1 Sensor Number", INTEGER, "enc1_sensor_num", params.enc1_sensor_num)
	dialog.control(d, "Extract Encoder 2 Data", CHECKBOX, "enc2_extract", params.enc2_extract)	
	dialog.control(d, "Encoder 2 Sensor Number", INTEGER, "enc2_sensor_num", params.enc2_sensor_num)	
	dialog.control(d, "Extract Encoder 3 Data", CHECKBOX, "enc3_extract", params.enc3_extract)	
	dialog.control(d, "Encoder 3 Sensor Number", INTEGER, "enc3_sensor_num", params.enc3_sensor_num)	
	dialog.control(d, "PORT RESTRICTIONS", BOX, FL_ENGRAVED_BOX)
	dialog.control(d, "Restrict to Specific Ports", CHECKBOX, "filter_ports",params.filter_ports)
	dialog.control(d, "TX Port Number", INTEGER, "tx_port_num", params.tx_port_num)	
	dialog.control(d, "RX Port Number", INTEGER, "rx_port_num", params.rx_port_num)	
	
	dialog.end_tab(d)
	
	dialog.begin_tab(d, "Extract II")

	dialog.control(d, "Output Start and Stop Times", CHECKBOX, "out_start_stop", params.out_start_stop)
	dialog.control(d, "-----------------------------------", BOX, FL_NO_BOX)
	dialog.control(d, "Output Header", CHECKBOX, "header", params.header)
	
	dialog.end_tab(d)
		
	dialog.begin_tab(d, "Format")

	dialog.control(d, "Output as ASCII", CHECKBOX, "out_ascii", params.out_ascii)
	dialog.control(d, "Output as BINARY", CHECKBOX, "out_bin", params.out_bin)
	
	dialog.end_tab(d)
	
	params = dialog.show(d)
end

function define_default_params()
	local t = {
		proc_file_dir = false,
		file_dir = "",
		proc_file1 = false,
		file1 = "",
		proc_file2 = false,
		file2 = "",
		proc_file3 = false,
		file3 = "",
		out_alt = false,
		out_alt_dir = "",
		norm = false,
		norm_file = "",
		norm_scan = 1,
		scale = false,
		scale_factor = 0.5,
		tw = false,
		tw_start = 0,
		tw_stop = 0,
		tw_hanning = false,
		bg_sub = false,
		bg_file = "",
		bg_sub_avg = false,
		sub_run_avg = false,
		sub_run_avg_nscans = 1,
		avg_frames = false,
		min_max_freq = false,
		min_max_dist = false,
		min_max_time = false,
		min_max_time_db = false,
		min_max_dist_corr = 0,
		snr = false,
		snr_target_dist = 0,
		snr_noise_dist = 0,
		clip1 = false,
		clip1_start = 1,
		clip1_stop = 1,
		clipN = false,
		clipN_nFrames = 1,
		clipTS = false,
		clipTS_start = 0,
		clipTS_stop = 10,
		clipTSN = false,
		clipTSNSeconds = 10,
		freq_range1 = false,
		freq_range_start1 = 0,
		freq_range_stop1 = 0,
		freq_range_ex = false,
		utm_correct = false,
		utm_easting_off = 0.0,
		utm_northing_off = 0.0,
		out_start_stop = false,
		header = false,
		pos_data = false,
		gps_sensor1 = false,
		gps_sensor_num1 = 1,
		gps_sensor2 = false,
		gps_sensor_num2 = 2,
		enc1_extract = false,
		enc1_sensor_num = 6,
		enc2_extract = false,
		enc2_sensor_num = 6,
		enc3_extract = false,
		enc3_sensor_num = 6,
		filter_ports = true,
		tx_port_num = 1,
		rx_port_num = 1,
		out_ascii = false,
		out_bin = false
	}
	return t
end

function corr_params(p)
	-- If the loaded parameters don't contain all of the parameters specified by default
	-- then the additional parameters will be added
	for k in pairs(p) do
		if (params[k] == nil) then
			params[k] = p[k]
		end
	end
	
	-- If the loaded parameters contain parameters that aren't specified by default
	-- then the additional parameters will be removed
	for k in pairs(params) do
		if (p[k] == nil) then
			params[k] = nil
		end
	end
end

function get_parameters()
	
	file_handle, err = io.open(PARAMS_FILE, "r")
	
	if err then
		params = define_default_params()
	else
		temp_params = define_default_params()
		params = L.read_table(PARAMS_FILE)
		corr_params(temp_params)
	end
	
	edit_parameters()
	
	if (params ~= nil) then 
		L.write_table(PARAMS_FILE, params)
	else
		error("User canceled operation")
	end

	return params
end