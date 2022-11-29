L = require("UTIL-Lua")
P = require("UTIL-Plot")

--------------------------------------------------------
CV = complex_vector
 V = vector

CM = complex_matrix
 M = matrix

-- SOURCE_NAME is bound to the surface window
-- that called this script. We can access the window
-- and its contents using it.

if SOURCE_NAME == "" then
	forms.error("Must be called from surface window only.")
end

m = surface.get_matrix(SOURCE_NAME)

fn = forms.get_filename("Save Matrix", "Text Files(*.txt)\tAll Files(*)")
print(fn)
file.write_complex_matrix(fn, m)