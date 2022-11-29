--
-- Util-Lua.lua
--

-----------------------------------------------------
local modname = ...

--------------------------------------------- --------
local M = {}

-----------------------------------------------------
_G[modname] = M

-----------------------------------------------------
package.loaded[modname] = M

-----------------------------------------------------
local CV = complex_vector
local V = vector

local CM = complex_matrix
local MM = matrix


-------------------------------------------------------------------------
function M.apply(f, ...) 
	return f(...)
end

-------------------------------------------------------------------------
function M.read_table(fn) 
	local t = {}
	function entry(b)
		t = b
	end
	dofile(fn)
	return t
end

-------------------------------------------------------------------------
function M.write_table(fn, t) 
	local file = io.open(fn, "w")
	M.serialize(file, t)
	file:close()
end

-------------------------------------------------------------------------
function M.serialize (file, o)
	if type(o) == "number" then
		file:write(o)
	elseif type(o) == "string" then
		file:write(string.format("%q", o))
	elseif type(o) == "boolean" then
		if o then
			file:write("true")
		else
			file:write("false")
		end
	elseif type(o) == "table" then
		file:write("entry{\n")
		for k,v in pairs(o) do
			file:write("  ", k, " = ")
			M.serialize(file, v)
			file:write(",\n")
		end
		file:write("}\n")
	  else
		error("cannot serialize a " .. type(o))
	end
end

-------------------------------------------------------------------------
function M.print_hex_string(s)
	if (addr == nil) then addr = 0 end
	for i = 1, #s, 2 do
		if ((i - 1) % 8 == 0) then
			io.write(" ")
		end
		if ((i - 1) % 16 == 0) then
			io.write(string.format("\n%04x  ", addr))
		end
		io.write(string.sub(s, i, i))
		io.write(string.sub(s, i + 1, i + 1))
		io.write(" ")
		addr = addr + 1
	end
	print("\n")
end	

-------------------------------------------------------------------------
function M.print_hex(s, addr)
	if (addr == nil) then addr = 0 end
	for i = 1, #s do
		if ((i - 1) % 4 == 0) then
			io.write(" ")
		end
		if ((i - 1) % 8 == 0) then
			io.write(string.format("\n%04x  ", addr + i - 1))
		end
		io.write(string.format("%02x ", string.byte(s, i) ))
	end
	print("\n")
end


function M.print_packet(packet)
	print(
		packet.PORT, packet.SENDER, 
		packet.NBYTE,
		packet.SWEEP_COUNT,
		packet.TX, 
		packet.RX,
		packet.TX_PORT, 
		packet.RX_PORT,
		packet.GAIN, 
		packet.PROCESS_INDEX )

	M.print_hex_string(packet.DATA)
	print("\n")

end

-------------------------------------------------------------------------
function M.print_table_aux(x)
	if type(x) == "table" then
		io.write("{")
		for k in pairs(x) do
			io.write("\n" .. k .. ": ")
			M.print_table_aux(x[k])
		end 
		io.write("\n}\n")
	else
		io.write(tostring(x) .." ")
	end
end

-------------------------------------------------------------------------
function M.print_table(x)
	if type(x) == "table" then
		io.write("{")
		for k in pairs(x) do
			io.write("\n" .. k .. ": ")
			M.print_table_aux(x[k])
		end 
		io.write("}\n")
	else
		io.write(tostring(x) .." ")
	end
end

-------------------------------------------------------------------------
function M.display(...)
	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if M.is_table(arg) then
			M.print_table(arg)
		elseif M.is_vector(arg) or M.is_complex_vector(arg) then
			for i = 1, #arg do
				if M.is_complex_vector(arg) then
					print(tostring(i) .. ": ", arg[i], " = ", complex.abs(arg[i]))
				else
					print(tostring(i) .. ": ", arg[i])
				end
			end
		elseif M.is_matrix(arg) or M.is_complex_matrix(arg) then
			if M.is_matrix(arg) then
				z1, z2 = MM.dims(arg) 
			else
				z1, z2 = CM.dims(arg)
			end
			for i = 1, z1 do
				io.write(tostring(i) .. ": ")
				for j = 1, z2 do
					io.write(tostring(arg[i][j]) .. " ")
				end
				print()
			end
		else
			print(arg)
		end
	end
end

-----------------------------------------------------
local function is_user_type(x, t)
	return type(x) == "userdata" and 
		getmetatable(x) == getmetatable(t)
end

-----------------------------------------------------
function M.is_vector(x)
	return is_user_type(x, V())
end

-----------------------------------------------------
function M.is_complex_vector(x)
	return is_user_type(x, CV())
end

-----------------------------------------------------
function M.is_complex_matrix(x)
	return is_user_type(x, CM())
end

-----------------------------------------------------
function M.is_matrix(x)
	return is_user_type(x, MM())
end

-----------------------------------------------------
function M.is_complex(x)
	return is_user_type(x, complex())
end

-----------------------------------------------------
function M.is_string(x)
	return type(x) == "string"
end

-----------------------------------------------------
function M.is_number(x)
	return type(x) == "number"
end

-----------------------------------------------------
function M.is_table(x)
	return type(x) == "table"
end

-----------------------------------------------------
function M.to_string(arg)
	return M.is_string(arg) and arg or ""
end

-----------------------------------------------------
function M.check_table(arg)
	return is_table(arg) and table or
		error( 
			debug.traceback( 
				string.format("expecting table type; received %s type", type(arg)) ))
end

-----------------------------------------------------
function M.check_vector(arg)
	return is_vector(arg) and arg or
		error( 
			debug.traceback( 
				string.format("expecting table type; received %s type", type(arg)) ))
end

-----------------------------------------------------
function M.check_complex(arg)
	return is_complex(arg) and arg or
		error( 
			debug.traceback( 
				string.format("expecting complex type; received %s type", type(arg)) ))
end

-----------------------------------------------------
function M.check_complex_vector(arg)
	return is_complex_vector(arg) and arg or
		error( 
			debug.traceback( 
				string.format("expecting complex_vector type; received %s type", type(arg)) ))
end

