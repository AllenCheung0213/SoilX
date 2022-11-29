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

function line3(pname1, pname2)
	T1 = tape[pname1]
	T2 = tape[pname2]
	T3 = tape[TIMESTAMP]
	T4 = tape[SWEEP_DELAY] * 1.e-3
	return { T3 - T4, T1 - T1[1], pname1, data_source.get_filename() },
		   { T3 - T4, T2 - T2[1], pname2, data_source.get_filename() }
end

function line2(pname1, pname2)
	T1 = tape[pname1]
	T2 = tape[pname2]
	return { T1 - T1[1], T2 - T2[1], pname1 .. " vs " .. pname2, data_source.get_filename() }
end

function line4(pname1, pname2)
	T1 = tape[pname1]
	T2 = tape[pname2]
	return { T1, T2, pname1 .. " vs " .. pname2, data_source.get_filename() }
end

--P(line(SWEEP_DELAY))
--P( line3(GPS_UTC, UTC) )

--P(line(GPS_HEADING))
--P(line(GPS_MILLISECOND))

--P1 = line(POS_LATITUDE)
--P2 = line(POS_LONGsITUDE)
--P3 = line(POS_HEIGHT)

--P(P1, P2, P3)
--P( line2(POS_LONGITUDE, POS_LATITUDE) )

--U1 = line(UTM_NORTHING)
--U2 = line(UTM_EASTING)
--U3 = line(UTM_HEIGHT)

--P( line4(UTM_EASTING, UTM_NORTHING) )
P( line3(UTM_EASTING, UTM_NORTHING) )
P( line4(TIMESTAMP, SWEEP_NUMBER) )

--P(U1, U2, U3)
