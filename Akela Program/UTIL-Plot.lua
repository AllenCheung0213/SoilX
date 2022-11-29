--
-- Util-Plot.lua
--

L = require("Util-Lua")

-----------------------------------------------------
local modname = ...

--------------------------------------------- --------
local M = {}

-----------------------------------------------------
_G[modname] = M

-----------------------------------------------------
package.loaded[modname] = M

-----------------------------------------------------
local trace = false

-----------------------------------------------------
local CV = complex_vector
local V = vector

-----------------------------------------------------
function M.set_trace(state) trace = state end


-----------------------------------------------------
local function crack_titles(...)
	return 
		L.to_string(select(1, ...)), 
		L.to_string(select(2, ...))
end


-----------------------------------------------------
-----------------------------------------------------
local function crack_table(t)

	if trace then print("crack_table:", t[1], t[2], t[3], t[4]) end

	if L.is_vector(t[1]) then
		if L.is_vector(t[2]) then
			return {t[1], t[2], crack_titles(t[3], t[4])}
		else
			return {V.new(#t[1], 0, 1), t[1], crack_titles(t[2], t[3])}
		end
	end

	if L.is_complex_vector(t[1]) then
		return {CV.real(t[1]), CV.imag(t[1]), crack_titles(t[2], t[3])}
	end

	error( 
		debug.traceback( 
			string.format("expecting either a vector or complex_vector; received %s type", type(t[1])) ))
end

-----------------------------------------------------
local function new_T_01(...)

	if trace then print("new_T_01:", ...) end

	local t = {}

	for i = 1, select("#", ...) do
		local arg = select(i, ...)
		if L.is_table(arg) then
			table.insert(t, crack_table(arg))
		else
			error( 
				debug.traceback( 
					string.format("expecting table type; received %s type", type(arg)) ))
		end
	end
	
	return t
end

-----------------------------------------------------
local function new_L_01(...)

	if trace then print("new_L_01:", ...) end

	if L.is_table(select(1, ...)) then
		return new_T_01(...)
	else
		if select("#", ...) > 0 then
			return {crack_table{...}}
		end
	end

	return {}

end


-----------------------------------------------------
local function new_W_01(ptype, pname, ...)
	
	if trace then print("new_W_01:", ptype, pname, ...) end

	local w = chart.new(ptype, pname, FL_CHART_WINDOW)
	chart.clear(w)

	local x = new_L_01(...)
	for i = 1, #x do
		chart.add(w, x[i][1], x[i][2], x[i][3], x[i][4])
	end

	chart.update(w)
	
	return w
	
end

-----------------------------------------------------
function M.new(...)

	if trace then print("new:", ...) end

	local arg1 = select(1, ...)
	if L.is_string(arg1) then
		local arg2 = select(2, ...)
		if L.is_string(arg2) then
			return new_W_01(arg1, arg2, select(3, ...))
		else
			return new_W_01(arg1, window_manager.make_name(), select(2, ...))
		end
	else
		return new_W_01("CHART", window_manager.make_name(), ...)
	end

end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.magnitude_frequency(...)
	local w = M.new("I(f)", ...)
	chart.set_xlabel(w, "Frequency (MHz)")
	chart.set_ylabel(w, "Magnitude (dB)")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.magnitude_frequency_abs(...)
	local w = M.new("I(f)", ...)
	chart.set_xlabel(w, "Frequency (MHz)")
	chart.set_ylabel(w, "Magnitude")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.magnitude_time(...)
	local w = M.new("M(t)", ...)
	chart.set_xlabel(w, "Time (ns)")
	chart.set_ylabel(w, "Magnitude")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.magnitude_time(...)
	local w = M.new("I(t)", ...)
	chart.set_xlabel(w, "Time (ns)")
	chart.set_ylabel(w, "Magnitude (dB)")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.magnitude_time_abs(...)
	local w = M.new("I(t)", ...)
	chart.set_xlabel(w, "Time (ns)")
	chart.set_ylabel(w, "Magnitude")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.phase_frequency(...)
	local w = M.new("theta(f)", ...)
	chart.set_xlabel(w, "Frequency (MHz)")
	chart.set_ylabel(w, "Phase (rad)")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.phase_time(...)
	local w = M.new("theta(t)", ...)
	chart.set_xlabel(w, "Time (ns)")
	chart.set_ylabel(w, "Phase (rad)")
	chart.update(w)
	return w
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
function M.append(w, ...)
	if trace then print("append:", ...) end
	local x = new_L_01(...)
	for i = 1, #x do
		chart.add(w, x[i][1], x[i][2], x[i][3], x[i][4])
	end
	chart.update(w)
	return w
end

setmetatable( M, { __call = function( _, ... ) return M.new( ... ) end } )

