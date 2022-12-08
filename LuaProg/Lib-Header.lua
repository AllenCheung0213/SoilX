-- Title: Standard Header
-- Filename: Lib-Header.lua
-- Description: Contains standard global variable and constant assigments
-- Version 1.1.0, 01/11/2011
-- Author: Patton Gregg
-- Revision History:
--	1.1.0, 01/11/2011
--		Added GATE_CALC_IF_OFFSET
--		Delete GATE_HARMON_THREAS
--	1.0.3, 12/21/2010
-- 		Added SC = data_scan
--	1.0.2, 12/08/2010
--		Added GATE_HARMON_THREAS
--	1.0.1, 11/30/2010
--		Added cInNanoSecPerM (Speed of Light) constant
--		Added GateClock constant
--	1.0.0, 11/30/2010
--		Initial Release
--------------------------------------------------------
 
 L = require("Util-Lua")
 P = require("Util-plot")

 V = vector
 M = matrix

 C = complex

CV = complex_vector
CM = complex_matrix

DS = data_source
DT = data_tape
SC = data_scan

WM = window_manager

 F = file

-- Constants
c = 299704764 -- (m/s)
cInNanoSecPerM = 3.33661 -- (ns/m)
GateClock = 6.10352 -- (ns)
GATE_CALC_IF_OFFSET = 0.5 -- (MHz)