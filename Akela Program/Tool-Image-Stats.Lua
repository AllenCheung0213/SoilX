L = require("UTIL-Lua")
P = require("UTIL-Plot")

if SOURCE_NAME == "" then
	forms.error("Must be called from surface window only.")
end

m = surface.get_matrix(SOURCE_NAME)

print(matrix.stats(complex_matrix.abs(m)))
