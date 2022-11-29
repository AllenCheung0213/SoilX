-- Title:		Send File
-- Description:	Use this tool to send a copy of the data file to a user specified
--			location once the data collection has stopped.
-- Usage: 		Specify the Select the method(s) you would like to use to send 
--			the file once the collection is complete by making the Method 
-- 			variable under "Parameters" below equal to true or false. Also,
--			specify location that file will be sent to for each method, and 
--			for the FTP method specify the username, password, and server 
--			address. Then, in the Data Editor Lua tab, enable this script in
--			the "Upon Writing" box. 
-- Author:		Patton Gregg
-- Version: 		1.00, 03/16/10

-- Parameters
copyMethod = true
copyDest = "C:\\Scripts" -- Must use \\ to specify a backslash

ftpMethod = false
-- ftpDest = ""
ftpUser = "sjbooths"
ftpPass = "cawcawcaw"
ftpAddr = "sjboothstudio.com"

-- Script Start
print("\n---SENDING FILE---\n")

function copyFile (source, destination)
	print("\nCopying File")
	print("copy \"" .. source .. "\" \"" .. destination .. "\"")
	os.execute("copy \"" .. source .. "\" \"" .. destination .. "\"")
end

function uploadFTP (username, password, pathname, currDir, filename, server)
	print("\nUploading File")
	os.execute("@echo off")
	os.execute("echo user " .. username .. "> ftpcmd.dat")
	os.execute("echo " .. password .. ">> ftpcmd.dat")
	os.execute("echo bin>> ftpcmd.dat")
	os.execute("echo lcd \"" .. currDir .. "\">> ftpcmd.dat")
	os.execute("echo pwd>> ftpcmd.dat")
	-- os.execute("echo cd " .. pathname .. ">>ftpcmd.dat")
	os.execute("echo put " .. filename .. ">> ftpcmd.dat")
	os.execute("echo quit>> ftpcmd.dat")
	os.execute("ftp -n -s:ftpcmd.dat " .. server)
	os.execute("del ftpcmd.dat")
end

filename = string.gsub(data_source.get_filename(), "/", "\\")
dir = string.gsub(string.sub(file.get_dir(filename), 1, -2), "/", "\\")
file = file.remove_dir(filename)
print("File:", file)

if (copyMethod) then
	copyFile(filename, copyDest)
end

if (ftpMethod) then
	uploadFTP(ftpUser, ftpPass, ftpDest, dir, file, ftpAddr)
end