-- creation
------------------------------------------------------------
texture() --> HANDLE
texture(TYPE) --> HANDLE
texture(TYPE, HANDLE) --> HANDLE

-- content
------------------------------------------------------------
texture.get(HANDLE, [frame_number = 1]) --> complex_matrix (FG), complex_matrix (BG), title, title
texture.set(HANDLE, matrix, [title], [title], [transpose = false] ) --> VOID
texture.set(HANDLE, matrix, matrix, [title], [title], [transpose = false] ) --> VOID

--Note: The set command appends a new frame.

-- control
------------------------------------------------------------
texture.update(HANDLE) --> VOID

-- scale
------------------------------------------------------------
texture.set_scale(X0, X1, Y0, Y1) --> VOID

-- titles and labels
------------------------------------------------------------
texture.set_title1(HANDLE, upper_title)
texture.set_title2(HANDLE, lower_title)

texture.get_title1(HANDLE) --> upper_title
texture.get_title2(HANDLE) --> lower_title

texture.set_xlabel(HANDLE, label)
texture.set_ylabel(HANDLE, label)

texture.get_xlabel(HANDLE) --> label
texture.get_ylabel(HANDLE) --> label

-- color
------------------------------------------------------------
texture.set_min_color(HANDLE, value) --> VOID
texture.set_max_color(HANDLE, value) --> VOID

texture.set_color_map(HANDLE, color_type) --> VOID
	w\a color_type = COLOR_MAP_COLOR, COLOR_MAP_GRAY

texture.set_background_blend(HANDLE, BOOL) --> VOID

