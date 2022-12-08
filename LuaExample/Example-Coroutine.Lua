L = require("UTIL-Lua")
P = require("UTIL-Plot")

dofile("LuaProg/UTIL-Header.Lua")

S = socket.open(34000)
print(S)


function foo()
	i = 0
	while true do
		i = i + 1
		socket.send(S, "HELLO" .. i)
		coroutine.yield("foo" .. i)
	end
end

function bar()
	i = 0
	while true do
		i = i + 1
		print(socket.receive(S))
		coroutine.yield("bar" .. i)
	end
end

co_foo = coroutine.create(foo)
co_bar = coroutine.create(bar)

co = {co_foo, co_bar}

for i = 1, 10 do
	for k,v in ipairs(co) do
		print(coroutine.resume(v))
	end
end
