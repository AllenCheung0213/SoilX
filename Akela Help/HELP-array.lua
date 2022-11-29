Plot = require("UTIL-Plot")
Lua = require("UTIL-Lua")

function pause()
	print(string.rep("*", 80))
	print(string.rep("*", 80))
	system.pause()
end

-- We can make arrays of any rank we like. However, the
-- first parameter is its type: 1:integer 2:number 3:complex
a1 = array(1, 3)
a2 = array(2, 3, 4)
a3 = array(3, 3, 4, 5)

-- Arrays have various attributes that can be seen by printing them.
print(a1)
print(a2)
print(a3)

pause()

-- Note that the print statement delegates to the 
-- tostring operator and we could have written instead:
print(tostring(a1))

-- So, a useful function will be a way to display arrays.
-- Note that array.display takes an optional description.
function display(a)	a:display(tostring(a)) end

pause()

-- Here's one way to make a table that looks like an array.
function make_table_array(initial_value)
	local t = {}
	for i = 1, 2 do
		t[i] = {}
		for j = 1, 3 do
			t[i][j] = {}
			for k = 1, 4 do
				t[i][j][k] = initial_value
			end
		end
	end
	return t
end

-- An array can be made from a table.
a4 = array(make_table_array(complex(0,0)))

-- Enumerate generates the sequence [1..length]
a4:enumerate()
display(a4)

pause()

-- Here's a more explicit way to make an array.
a5 = array{{11,12,13},{21,22,23}}
display(a5)

pause()

-- We need to modify the array. _at indicates that the
-- index is a linear index relative to the array's length.
a3:set_at(1, complex(1111,1111))

-- We need to be able to access the array.
print(a3:ref_at(1))

--a3:ref(coord)
--a3:set(coord, v)

pause()

a3:enumerate()

-- A slice can modify an array's size, but not its length.
-- Note that the addresses of a4 and a3 are equal.
a4 = a3:slice(5, 2, 10, 3, 2)
print(a3)
print(a4)

-- Hence, if I change one, I change the other.
a3:set_at(6, 9999)
print(a3:ref_at(6))
display(a4)

-- Unless I make a copy.
a4 = a3:slice(5, 2, 10, 3, 2):copy()
a3:set_at(6, 1111)
print(a3:ref_at(6))
display(a4)

-- Beware, though, a slice-of-a-copy is not
-- the same thing as a copy-of-a-slice. Note
-- the array's length attribute.
print(a3:slice(5, 2, 10, 3, 2):copy())
print(a3:copy():slice(5, 2, 10, 3, 2))

print("DONE")
