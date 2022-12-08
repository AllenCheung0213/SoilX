  L = require("UTIL-Lua")
P = require("UTIL-Plot")

-- Initialize is called when the user
-- activates the filter using the apply
-- button and before data is collected.
function Initialize()
	w = window_manager.make(FL_TEXT_WINDOW)
end

-- Process is called for each combination and is passed
-- a data_scan object.
function Process(scan)

	t = {
		string.format("GPS Heading:      %d", scan.GPS_HEADING),
		string.format("GPS Time Status:  %d", scan.GPS_TIME_STATUS),
		string.format("GPS Week          %d", scan.GPS_WEEK),
		string.format("GPS Milliseconds: %d", scan.GPS_MILLISECOND),
		string.format("POS Latitude:     %f", scan.POS_LATITUDE),
		string.format("Pos Longitude:    %f", scan.POS_LONGITUDE),
		string.format("POS Height:       %f", scan.POS_HEIGHT),
		string.format("UTM Northing:     %f", scan.UTM_NORTHING),
		string.format("UTM Easting:      %f", scan.UTM_EASTING),
		string.format("UTM Height        %f", scan.UTM_HEIGHT) }
	
	window_manager.update(w, t)
	return scan
end
