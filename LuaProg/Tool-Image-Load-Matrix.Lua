L = require("UTIL-Lua")
P = require("UTIL-Plot")

fn = forms.get_filename("Load Matrix", "Text Files(*.txt)\tAll Files(*)")
print(fn)

m = file.read_complex_matrix(fn)

s = surface(fn)
t1 = surface.set_title1(s, fn)
surface.set(s, m)
surface.update(s)

