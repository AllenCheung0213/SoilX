
tape = data_source.get_tape()
new_tape = data_tape.apply_active_filters(tape)
data_source.set_tape(new_tape)




