-- Title: Type Functions
-- Filename: Lib-Type.lua
-- Description: Functions for checking and converting variable types
-- Version 1.0.0, 11/30/10
-- Author: Patton Gregg
-- Revision History:
--	1.0.0, 11/30/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- BoolToInt(bool) -> int
-- BoolToString (int) -> string
-- IntToBool(int) -> bool
-- IsBool (variable) -> bool
-- IsNum (variable) -> bool
-- IsDataFile (file_path_string) -> bool
-- StringToBool (string) -> bool
--------------------------------------------------------

-- Checks to see if variable is a bool
function IsBool(v)

	if string.upper(v) == "TRUE" or string.upper(v) == "FALSE" then
		return true
	end
	
	return false	
end

-- Checks to see if variable is a number
function IsNum (v)
	return type(tonumber(v)) == "number"
end

-- Checks to see if the file is an APRD data file
function IsDataFile (filename)

	if file.get_ext(filename) == ".imb" then
		return true
	elseif file.get_ext(filename) == ".img" then
		return true
	elseif file.get_ext(filename) == ".imx" then
		return true
	else
		return false
	end
end

-- Returns a bool from a string input
function StringToBool (s)

	if string.upper(s) == "TRUE" then
		return true
	end
	
	return false
end

-- Returnd string from a bool input
function BoolToString (v)

	if v then
		return "TRUE"
	end
	
	return "FALSE"
end

-- Returns bool from a number input
function IntToBool(v)

	if v == 1 then
		return true
	end
	
	return false
end

-- Returns number from a bool input
function BoolToInt(v)

	if v then
		return 1
	end
	
	return 0
end