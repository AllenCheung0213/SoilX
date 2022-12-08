file.read_vector(filename) --> vector
file.read_matrix(filename) --> matrix
	
file.read_complex_vector(filename) --> complex_vector
file.read_complex_matrix(filename) --> complex_matrix

file.write_vector(filename, vector) --> VOID
file.write_matrix(filename, matrix) --> VOID
	
file.write_complex_vector(filename, complex_vector) --> VOID
file.write_complex_matrix(filename, complex_matrix) --> VOID

file.read_marker_vector(filename) --> complex_vector of (X, Y)
file.read_marker_table(filename) --> {FILENAME {LABEL, X, Y, Z} ...}

file.write_marker_vector(filename, complex_vector of (X, Y)) --> VOID
file.write_marker_table(filename, {FILENAME {LABEL, X, Y, Z} ...}) --> VOID

file.get_CWD() --> string

file.get_directory(dirname) -> { filename, filename ... }
file.get_directory_structure(dirname) -> { table, table ... }

	w/ table contains following entries:
	
		IS_READ_ONLY
		IS_SYSTEM
		IS_HIDDEN
		IS_ARCHIVE
		IS_DIRECTORY
		FILE_SIZE
		PATHNAME -- relative path to file
		FILENAME -- filename
		ABSOLUTE -- full expanded path + filename

file.get_absolute(string) --> string
file.get_expanded(string) --> string
file.get_relative(string) --> string
file.get_ext(string) --> string
file.get_dir(string) --> string
file.get_name(string) --> string
file.set_ext(filename, ext) --> string
file.set_dir(filename, dir) --> string
file.remove_dir(string) --> string
file.increment(filename, ext) --> string
file.auto_name(string) --> string
file.auto_counter(string) --> integer
file.auto_symbol(string) --> char
file.is_dir(string) --> bool
file.is_file(string) --> bool
file.is_valid(string) --> bool
file.get_size(string) --> integer
file.create_file(string) --> VOID
file.create_directory(string) --> VOID
file.concatenate(string1, string2) --> string
