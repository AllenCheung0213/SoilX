-- Title: Table Functions
-- Filename: Lib-Table.lua
-- Description: Functions for Lua tables
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
-- DisplayTable(table, desc_string) -> VOID
-- AppendTable (table1, table) -> modified table1 .. table
--------------------------------------------------------

-- Prints the tables contents to the console
function DisplayTable(t, desc)
	function DisplayTableL2(desc, t)
		for k,v in pairs(t) do
			print(string.format("%20s %20s", desc, k), v)
		end
	end	

	print("---------------------------------------------------")
	print(desc)
	print("---------------------------------------------------")
	for k, v in pairs(t) do
		if L.is_table(v) then
			DisplayTableL2(k, v)
		else
			print(string.format("%20s", k), v)
		end
	end
end

-- Appends table2 to table1
function AppendTable (table1, table2)

	for k,v in pairs(table2) do
		table1[k] = v
	end
	
	return table1
end