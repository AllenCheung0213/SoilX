L = require("UTIL-Lua")
P = require("UTIL-Plot")

tape = data_source.get_tape()[ function(x) return x.RX == 2 and x.TX_PORT == 1 and x.RX_PORT == 1 end ]

function line(pname, offset)
	if offset == nil then
		return { tape[pname], pname, data_source.get_filename() }
	else
		return { tape[pname] + offset, pname, data_source.get_filename() }
	end
end

function line2(pname1, pname2)
	T1 = tape[pname1]
	T2 = tape[pname2]
--	return { T1 + 2.41, T2 - 4.51, pname1 .. " vs " .. pname2, data_source.get_filename() }
	return { T1, T2, pname1 .. " vs " .. pname2, data_source.get_filename() }
end


P( line2(UTM_EASTING, UTM_NORTHING) )


GT = config.get_ground_truth_table("CT-6 All Zones Standoff 05.txt")

 C = complex
CV = complex_vector

gt = CV()
for k,v in pairs(GT) do
	x = v.EASTING
	y = v.NORTHING
	CV.append(gt, C(x, y))
end 

P(gt)


