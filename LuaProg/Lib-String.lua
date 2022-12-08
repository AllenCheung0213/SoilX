-- Title: String Functions
-- Filename: Lib-String.lua
-- Description: Functions related to manipulating strings
-- Version 1.0.0, 02/24/2011
-- Author: Patton Gregg
-- Revision History:
--	1.0.0, 02/24/2011
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- GetCommaSepNums (str) = vector, bool
--------------------------------------------------------

-- Takes a string of comma separated numbers and returns a vector of the numbers
function GetCommaSepNums (str)

	local value = V()
	local j = 0
	local buff
	local state = 1
	local err = false
	while true do
		_, j, char = string.find(str, "([%p%d ])", j+1)

		if (char == " ") then
			if (state == 2 or state == 3) then
				V.append(value, buff)
				buff = ""
			end
			state = 1
		elseif (IsNum(char)) then
			if (state == 1) then
				buff = char
				state = 2
			elseif (state == 2 or state == 3) then
				buff = buff .. char
			end
		elseif (char == ",") then
			if (state == 1) then
				err = true
				break
			elseif (state == 2 or state == 3) then
				V.append(value, buff)
				buff = ""
				state = 1
			end
		elseif (char == ".") then
			if (state == 2) then
				buff = buff .. char
				state = 3
			else
				err = true
				break
			end
		elseif (char == nil) then
			if (state == 1) then
				err = true
			elseif (state == 2 or state == 3) then
				V.append(value, buff)
			end
			break
		end
	end

	return value, err
end