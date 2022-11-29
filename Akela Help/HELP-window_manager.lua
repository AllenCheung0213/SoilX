window_manager.make(type) --> name
window_manager.make(type, isLocked) --> name
window_manager.make(type, name, isLocked) --> name

window_manager.activate() --> VOID

window_manager.close_all() --> VOID

window_manager.tile(isRestricted = false) --> VOID
window_manager.cascade(isRestricted = false) --> VOID

window_manager.tile_restricted() --> VOID
window_manager.cascade_restricted() --> VOID

window_manager.lock(name) --> VOID
window_manager.unlock(name) --> VOID

window_manager.lock() --> VOID  Locks all windows
window_manager.unlock() --> VOID  Unlocks all windows
window_manager.islocked() --> BOOL

-- Editor Functions
window_manager.load_file(name, filename) --> VOID
window_manager.append_text(name, string) --> VOID
window_manager.run(name) --> VOID
window_manager.set_changed(name[, state = true]) --> VOID
window_manager.is_changed(name) --> BOOL

window_manager.run_modal(name) --> VOID

window_manager.find(name) --> BOOL
window_manager.update(name) --> VOID

window_manager.make_name() --> name

window_manager.select_tab(name, tab_name) --> VOID
window_manager.remove_tab(name, tab_name) --> VOID
window_manager.insert_tab(name, tab_name, {before_tab_name}) --> VOID
window_manager.insert_tab(name, tab_name, {tab_index}) --> VOID

window_manager.get_window_type(name) -->  STRING
window_manager.is_window_type(name. STRING)
