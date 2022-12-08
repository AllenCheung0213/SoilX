L = require("UTIL-Lua")
P = require("UTIL-Plot")

-- Initialize is called when the user
-- activates the filter using the apply
-- button and before data is collected.
function Initialize()
	print("Initialize")
end

function IsMatched(scan)

	return (scan.TX) % 2 == (scan.RX) % 2

end

-- Process is called for each combination and is passed
-- a data_scan object.
function Process(scan)

	if IsMatched(scan) == false then
		scan.DATA = -(scan.DATA)
	end

	--P("SCAN", "SCAN", complex_vector.dec(scan.DATA))
	return scan

end
