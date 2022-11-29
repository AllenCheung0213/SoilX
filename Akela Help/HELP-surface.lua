-- creation
------------------------------------------------------------
surface() --> HANDLE
surface(TYPE) --> HANDLE
surface(TYPE, HANDLE) --> HANDLE

-- content
------------------------------------------------------------
surface.get_matrix(HANDLE) --> complex_matrix
surface.set_matrix(HANDLE, complex_matrix, [transpose = false] ) --> VOID
surface.set_matrix(HANDLE, complex_matrix, complex_matrix, [transpose = false] ) --> VOID

-- control
------------------------------------------------------------
surface.update(HANDLE) --> VOID

-- scale
------------------------------------------------------------
surface.set_scale(HANDLE, X0, X1, Y0, Y1) --> VOID
surface.set_log_scale(HANDLE, bool) --> VOID
surface.set_local_scale(HANDLE, bool) --> VOID

surface.set_user_scale(HANDLE, bool) --> VOID
surface.set_user_scale(HANDLE, min, max) --> VOID		Note: Sets state true.

-- titles and labels
------------------------------------------------------------
surface.get_title1(HANDLE) --> upper_title
surface.get_title2(HANDLE) --> lower_title

surface.set_title1(HANDLE, upper_title)
surface.set_title2(HANDLE, lower_title)

surface.get_xlabel(HANDLE) --> xlabel
surface.get_ylabel(HANDLE) --> ylabel

surface.set_xlabel(HANDLE, ylabel)
surface.set_ylabel(HANDLE, ylabel)

-- color
------------------------------------------------------------
surface.set_min_color(HANDLE, value) --> VOID
surface.set_max_color(HANDLE, value) --> VOID

surface.get_min_color(HANDLE, value) --> VOID
surface.get_max_color(HANDLE, value) --> VOID

surface.set_color_map(HANDLE, color_type) --> VOID
	w\ color_type = COLOR_MAP_COLOR, COLOR_MAP_GRAY

-- markers
------------------------------------------------------------
surface.get_marker_table(name) --> {FILENAME {LABEL, X, Y, Z} ...}
surface.set_marker_table(name, {FILENAME {LABEL, X, Y, Z} ...}) --> VOID

surface.get_marker_vector(name) --> complex_vector of (X, Y)
surface.set_marker_vector(name, complex_vector of (X, Y)) --> VOID

-- ground truth
------------------------------------------------------------
surface.get_ground_truth_table(name) --> {FILENAME {LABEL, X, Y, Z} ...}
surface.set_ground_truth_table(name, {FILENAME {LABEL, X, Y, Z} ...}) --> VOID

surface.get_ground_truth_vector(name) --> complex_vector of (X, Y)
surface.set_ground_truth_vector(name, complex_vector of (X, Y)) --> VOID

surface.set_position(x, y, z, theta) --> VOID
