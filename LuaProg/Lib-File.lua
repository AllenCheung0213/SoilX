-- Title: File Functions
-- Filename: Lib-File.lua
-- Description: Functions related to file I/O and filenames
-- Version 1.1.1, 02/24/2011
-- Author: Patton Gregg
-- Revision History:
--	1.1.1, 02/24/2011
--		Added function DirExists to check if a directory exists
--	1.1.0, 01/11/2011
--		Added a parameter to pass a description to append to the output filename for ChartFileOut
--	1.0.1, 12/16/2010
--		Moved output_header function from Tool-Data-Proc and renamed OutputHeader 
--		Added function ChartFileOut to write out a chart file
--	1.0.0, 11/30/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- DirExists (dir_path) -> bool
-- FileExists (file_path) -> bool
-- ChopExtension (filename) -> string
-- DataFileOut (tape, data_filename, desc) -> VOID
-- ChartFileOut (w, filename, desc) -> VOID
-- OutputHeader(file_path) -> VOID
--------------------------------------------------------

-- Returns a bool indicating of a file exists
function DirExists (dir_path)
	
	local dir = file.get_dir(dir_path)
	local dirABS = file.get_absolute(dir)
	
	local valid = true
	local ptr, err, err2 = io.open(dirABS, "r")

	-- APRD reports an error of type 2 when a file or directory doesn't exist
	if err2 == 2 then
		valid = false
	end
	
	return valid
end

-- Returns a bool indicating of a file exists
function FileExists (file_path)
	
	local valid = true
	local file_ptr, err = io.open(file_path, "r")

	if err ~= nil then
		valid = false
	end
	
	return valid
end

-- Removes the file type extention from the end of a filename
function ChopExtension (filename) 

	local fname = ""
	local ext = ""

	if string.find(filename, "%p%a%a%a", -4) then
		fname = string.sub(filename, 1, -5)
		ext = string.sub(filename, -4)
	else
		fname = filename
	end

	return fname, ext
end

-- Write a data tape to a file
function DataFileOut (tape, data_filename, desc)

	local filename, ext = ChopExtension(data_filename)
	
	if desc == nil then
		desc = ""
	end
	
	if string.find(desc, 'CONV_FORMAT') ~= nil then
		if string.find(desc, 'ASCII') ~= nil then
			ext = ".img"
		elseif string.find(desc, 'HEX') ~= nil then
			ext = ".imx"
		elseif string.find(desc, 'BIN') ~= nil then
			ext = ".imb"
		end
		filename = filename .. ext
	else
		desc = string.gsub(desc, "/.", "p")
		filename = filename .. desc .. ext
	end

	--! For some reason there is an error when you select "Yes" from the form and it tries to write out the file 
	-- if (FileExists(filename)) then
		-- local overwrite_file = forms.yes_no("File: " .. filename .. " already exists. Overwrite file?")

		-- if (overwrite_file ~= 6) then
			-- forms.message("File: " .. filename .. " was not output.")
		-- else
			-- print ("\n------------------------------------")
			-- print ("File Output:", filename)
			-- print ("------------------------------------\n")
			-- data_tape.write(tape, filename)
		-- end
	-- else
		print ("\n------------------------------------")
		print ("File Output:", filename)
		print ("------------------------------------\n")
		data_tape.write(tape, filename)
	-- end
end

-- Writes a chart to file
function ChartFileOut (w, filename, desc)
	
	local fileOut = ChopExtension(filename)
	fileOut = fileOut .. desc .. ".cha"
	chart.write(w, fileOut)
	
	print ("\n------------------------------------")
	print ("Chart File Output:", fileOut)
	print ("------------------------------------\n")
end

-- Writes the header of a data file out as a separate text file
function OutputHeader(data_file)

	io.input(data_file)
	
	local filename, ext = ChopExtension(data_file)
	filename = filename .. " - HEADER.txt"
	io.output(filename)

	local header = ""
	local data_line = io.read()
	data_line = data_line .. "\n"
	
	local scans_start = ""
	
	if (ext == ".img") then
		scans_start = "Scan\n"
	elseif (ext == ".imx") then
		scans_start = "@"
	elseif (ext == ".imb") then
		scans_start = "EOH"
	end
	
	while string.find(data_line, scans_start) == nil do 
		header = header .. data_line
		data_line = io.read() .. "\n"
	end
	
	io.write(header)
end