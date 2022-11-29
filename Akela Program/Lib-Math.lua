-- Title: Math Functions
-- Filename: Lib-Math.lua
-- Description: Functions for performing routine math operations
-- Version 1.2.2, 01/27/11
-- Author: Patton Gregg
-- Revision History:
--	1.3.0, 01/27/2011
--		Added: DistPoint2Line function
--	1.2.2, 01/27/2011
--		Fixed bug in CalcRMS function
--	1.2.1, 01/10/2011
--		Added CalcRMS function
--	1.2.0, 12/21/2010
-- 		Added GetMagCV function
-- 		Added GetCurrPos function
--	1.0.1, 12/17/2010
-- 		Added MinMaxCompareV function
--	1.0.0, 11/30/2010
--		Initial Release
--------------------------------------------------------
-- Include Files
--------------------------------------------------------
dofile("LuaProg/Lib-Header.lua")
--------------------------------------------------------
-- Function List
--------------------------------------------------------
-- Round (number) -> number
-- N2Order (number) -> number
-- N2OrderFloor (number) -> number
-- Order2N (number) -> number
-- Dist2D (x1, y1, x2, y2) -> number
-- Dist3D (x1, y1, z1, x2, y2, z2) -> number
-- DistPoint2Line (pointX, pointY, lineStartX, lineStartY, lineEndX, lineEndY) -> number
-- MinMaxCompareV (data, minV, maxV) -> min_vector, max_vector
-- GetMagCV (complex_v) -> vector
-- GetCurrPos (x, y, z, v, ang, deltaT) -> number
-- GetCurrPosBreath (x, y, z, rate, throw, ang, curr_t) -> number
-- CalcRMS (vector) -> number
-- CalcSigRMS (dataTime, sigDist, timeStep) -> number
--------------------------------------------------------
-- Returns the input number rounded to the nearest whole number
function Round (num)
-- function Round (num, sigFigs)
	
	local roundNum = nil
	
	if (num - math.floor(num) > 0.5) then
		roundNum = math.ceil(num)
	else
		roundNum = math.floor(num)
	end
	
	return roundNum
end

-- Returns n for the order of the next factor of 2^n
function N2Order (n) 
	return math.ceil(math.log10(n) / math.log10(2))
end

-- Returns n for the order of the closest previous factor of 2^n
function N2OrderFloor (n) 
	return math.floor(math.log10(n) / math.log10(2))
end

-- Returns 2 ^ n
function Order2N (order) 
	return 2 ^ order
end

-- Returns the absolute distance between 2 points in 2D space
function Dist2D (x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

-- Returns the absolute distance between 2 points in 3D space
function Dist3D (x1, y1, z1, x2, y2, z2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2 + (z2 - z1)^2)
end

-- Returns the closest distance between a point and a line
function DistPoint2Line (pointX, pointY, lineStartX, lineStartY, lineEndX, lineEndY)
	local numer = ((pointX - lineStartX) * (lineEndX - lineStartX))
					+ ((pointY - lineStartY) * (lineEndY - lineStartY))
	local denom = Dist2D(lineStartX, lineStartY, lineEndX, lineEndY) ^ 2
	
	local u = numer / denom

	local interX = lineStartX + u * (lineEndX - lineStartX)
	local interY = lineStartY + u * (lineEndY - lineStartY)

	local distPoint2Line = Dist2D(pointX, pointY, interX, interY)

	return distPoint2Line
end

-- Returns a vector of the maximum values from two vectors
function MinMaxCompareV (data, minV, maxV)

	local maxCompareM = M(2, #data)
	local minCompareM = M(2, #data)
	
	if (#maxV == 0) then
		maxV = data
		minV = data
	else
		maxCompareM[1] =  maxV
		maxCompareM[2] =  data
		maxV = M.max(maxCompareM)

		minCompareM[1] = minV
		minCompareM[2] = data
		minV = M.min(minCompareM)
	end

	return minV, maxV
end

-- Returns a vector of magitudes from a complex vector of quadriture values
function GetMagCV (complex_v) 
	return 20*V.log10(CV.abs(complex_v)) 
end

-- Returns the position of a target from a given intial position, velocity of motion, angle of motion,
-- the difference in time since the initial time
function GetCurrPos (x, y, z, v, ang, deltaT)

	pos = C(2)
	pos[1] = x + (v * math.sin(ang) * deltaT)
	pos[2] = y + (v * math.cos(ang) * deltaT)

	return pos
end

-- Returns the current position of a breathing target
-- rate = rate of breathing motion in cycles per minute
-- displacement = size of breathing motion in meters
function GetCurrPosBreath (x, y, z, rate, throw, ang, curr_t)
	
	local in2m = 0.0254
	local rateFactor = rate / 10

	pos = C(2)
	pos[1] = x + (throw * in2m * math.sin(curr_t * rateFactor) * math.sin(ang))
	pos[2] = y + (throw * in2m * math.sin(curr_t * rateFactor) * math.cos(ang))

	return pos
end

-- Returns the calculated RMS from a vector of values
function CalcRMS (v)
	
	local vSquared = v^2
	local rms = math.sqrt(V.avg(vSquared))
	
	return rms
end

-- Returns the RMS of a time domain signal
function CalcSigRMS (dataTime, sigDist, timeStep)
	
	local sigTime = sigDist * cInNanoSecPerM * 2
	local sigI = GetTimeIndex(sigTime, timeStep)

	if (sigI < 1) then sigI = 1 end
	
	local dataTargetSig = CM.slice2(dataTime, sigI, sigI)
	local dataTargetSigAmp = M.transpose(CM.abs(dataTargetSig))
	
	local rms = CalcRMS(dataTargetSigAmp[1])

	return rms	
end