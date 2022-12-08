Lua.print_table(x) --> VOID
Lua.read_table(filename) --> TABLE
Lua.write_table(filename, table) --> VOID
Lua.serialize(file, table) --> VOID
Lua.display(...) --> VOID

Lua.is_vector(x) --> BOOL
Lua.is_complex_vector(x) --> BOOL
Lua.is_complex(x) --> BOOL
Lua.is_string(x) --> BOOL
Lua.is_number(x) --> BOOL
Lua.is_table(x) --> BOOL
Lua.to_string(x) --> BOOL

Lua.check_table(x) --> is_table(x) ? x : error
Lua.check_vector(x) --> is_vector(x) ? x : error
Lua.check_complex(x) --> is_complex(x) ? x : error
Lua.check_complex_vector(x) --> is_complex_vector(x) ? x : error
