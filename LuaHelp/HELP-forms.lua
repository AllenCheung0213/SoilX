forms.ok_cancel(message) --> yes | no
forms.yes_no_cancel(message) --> yes | no
forms.yes_no(message) --> yes | no

Note: The following FORM-CONSTANTS are RETURNED, below:

	IDCANCEL Cancel button was selected. 
	IDNO No button was selected. 
	IDOK OK button was selected. 
	IDYES Yes button was selected. 

forms.error(message) --> VOID		-- displays message box and exits
forms.warning(message) --> VOID		-- displays message box
forms.message(message) --> VOID		-- displays message in console window

forms.get_filename(title, pattern) --> filename
	Example pattern:  "Marker Files(*.txt)\tAll Files(*.*)"

forms.get_working_dir() --> dirname
forms.set_working_dir(dirname) --> VOID

forms.input(string) --> string, FORM-CONSTANT
forms.input(string, default) --> string, FORM-CONSTANT

Note: Input returns in its 2nd result either IDCANCEL
      or IDOK.
