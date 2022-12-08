--
-- Example-Minimal-Data-Filter
--

progname = "Loading Example-Minimal-Data-Filter.lua"

print("Loading Example-Minimal-Data-Filter.lua")

-- Initialize is called when the user
-- activates the filter using the apply
-- button and before data is collected.
function Initialize()
	print(progname)
end

-- Process is called for each combination and is passed
-- a data_scan object.  Process must return a data_scan.
function Process(scan)
	print(progname)
	print(scan.FORMAT)
	return scan
end
