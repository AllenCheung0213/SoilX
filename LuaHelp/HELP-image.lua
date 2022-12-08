-----------------------------------------------------------------------------
--- Makes and initializes a new image
-----------------------------------------------------------------------------
image() --> IMAGE
image(analysis_parameter_table) --> IMAGE

image.initialize(IMAGE) --> VOID
image.initialize(IMAGE, image_parameter_table) --> VOID

-----------------------------------------------------------------------------
--- Image Properties and Coordinates
-----------------------------------------------------------------------------
print(IMAGE) --> image(image_height, image_width)
#IMAGE --> image_height

image.dims(IMAGE) --> height, width

image.get_scale(IMAGE) --> X0, X1, Y0, Y1
image.get_scale_offset(IMAGE) --> Z

image.get_image_cell_size(IMAGE) --> NUMBER
image.get_range_cell_size(IMAGE) --> NUMBER

image.get_range_index(IMAGE, TX, RX) --> matrix_of_range_indexes
image.get_range_frac(IMAGE, TX, RX) --> matrix_of_range_cell_fractions
image.get_range_dcorr(IMAGE, TX, RX) --> matrix_of_distance_corrections
image.get_range_distance(IMAGE, TX, RX) --> matrix_of_bi-static_distances

----------------------------------------------------------------------
-- Converts image index pairs (row,col) into image coordinates (x,y).
----------------------------------------------------------------------
image.convert(IMAGE, integer, integer) --> complex
image.convert(IMAGE, complex) --> complex
image.convert(IMAGE, complex_vector) --> complex_vector
image.convert(IMAGE, complex_matrix) --> complex_matrix

-----------------------------------------------------------------------------
-- Image Manager Functions
-----------------------------------------------------------------------------
image.start_new_image_frame(IMAGE) -->VOID

image.update_image_frame(IMAGE, time_stamp, TX, RX, complex_vector) --> VOID

image.assemble_image_frame(IMAGE) -> VOID
image.assemble_image_frame(IMAGE, is_statistical) -> VOID

image.get_image_frame(IMAGE) --> complex_matrix
image.get_image_frame(IMAGE, X0, X1, Y0, Y1) --> complex_matrix

image.set_image_frame(IMAGE, complex_matrix) --> VOID

image.get_position(IMAGE) --> return x, y, z, theta

-----------------------------------------------------------------------------
--- Top-level Image Routines
-----------------------------------------------------------------------------
image.make_image(IMAGE, tape) --> VOID
image.make_image(IMAGE, tape, is_statistical) --> VOID

image.get_image(IMAGE, tape) --> complex_matrix
image.get_image(IMAGE, tape, is_statistical) --> complex_matrix


