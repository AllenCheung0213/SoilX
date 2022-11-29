dialog([title], [width], [height], [left_margin], [right_margin]) --> handle
dialog.begin_tab(handle, tabname) --> VOID
dialog.end_tab(handle) --> VOID
dialog.control(handle, descr, var_type, var_name, default) --> VOID
dialog.show(handle) --> { var_name: value,  ... }
dialog.update(name, value) --> VOID

where var_type is one of:
	
	STRING INTEGER NUMBER FILE DIR CHECKBOX BOX
	
Note that BOX type does not return a value and its var_name indicates
one of the following box subtypes from FLTK:

	FL_NO_BOX
	FL_FLAT_BOX
	FL_UP_BOX
	FL_DOWN_BOX
	FL_UP_FRAME
	FL_DOWN_FRAME
	FL_THIN_UP_BOX
	FL_THIN_DOWN_BOX
	FL_THIN_UP_FRAME
	FL_THIN_DOWN_FRAME
	FL_ENGRAVED_BOX
	FL_EMBOSSED_BOX
	FL_ENGRAVED_FRAME
	FL_EMBOSSED_FRAME
	FL_BORDER_BOX
	FL_BORDER_FRAME
	
Note that FILE control takes an optional 6th parameter equal
to the file extension.
