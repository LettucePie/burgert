extends Control
class_name Options

signal containered_lang_selection(idx)


func _on_set_lang_pressed() -> void:
	if get_window().get_child(0) is GameContainer:
		var popup : PopupMenu = $Panel/VBoxContainer/set_lang.get_popup()
		var window : Window = get_window()
		var new_pos := Vector2i(window.size.x / 3, 0)
		var new_size := Vector2i(window.size.x / 3, window.size.y)
		popup.position = new_pos
		popup.size = new_size
