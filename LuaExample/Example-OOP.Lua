L = require("UTIL-Lua")

function X(p1, p2)
	local E = {}
	E.f1 = function () print(p1) end
	E.f2 = function () print(p2) end
	E.sum = p1 + p2
	return E
end

x1 = X(1111, 2222)
x2 = X(8888, 9999)

x1.f1()
x1.f2()
x2.f1()
x2.f2()

print(x1.sum)
print(x2.sum)

for i = 1, 10 do
	x1[i] = x1.sum + i
end

L.display(x1)
	
