--
-- Util-Queue.lua
--

-----------------------------------------------------
local modname = ...

modname = modname and modname or "TEST"

--------------------------------------------- --------
local M = {}

-----------------------------------------------------
_G[modname] = M

-----------------------------------------------------
package.loaded[modname] = M

function M.push(Q, v) 
	table.insert(Q.Q, v)
	if Q.N ~= nil and #Q.Q > Q.N then
		table.remove(Q.Q, 1)
	end
end

function M.pop(Q) 
	v = Q.Q[1]
	table.remove(Q.Q, 1)
	return v
end

function M.top(Q) return Q.Q[1] end
function M.bottom(Q) return Q.Q[#Q.Q] end

function M.get(Q, i) 
	return Q.Q[#Q.Q - i + 1]
end

function M.avg(Q, start, finish)

	start = start and start or 1
	finish = finish and finish or #Q.Q

	local S = M.get(Q, start)
	for i = start + 1, finish do
		S = S + M.get(Q, i)
	end
	return S / (finish - start + 1)
end


-----------------------------------------------------
function M.new(N) 
	local T = {}
	T.Q = {}
	T.N = N
	return T 
end

setmetatable( M, { __call = function( _, ... ) return M.new( ... ) end } )
