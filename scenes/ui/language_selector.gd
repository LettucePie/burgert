extends Control
class_name LanguageSelector

signal language_selector_finished()

@onready var scroll : ScrollContainer = $VBoxContainer/ScrollContainer
@export var directory : Control
@export var entry_original : Button

var language_options : Array = []


func _ready():
	pass
	#directory.remove_child(entry_original)


func populate_list(languages : PackedStringArray, callback : Callable):
	print("Populating language selector with languages: ", languages)
	if language_options.size() > 0:
		for lo in language_options:
			lo.queue_free()
	language_options.clear()
	var idx : int = 0
	for l in languages:
		var new_entry : Button = entry_original.duplicate()
		new_entry.name = str(idx)
		new_entry.text = l
		new_entry.pressed.connect(callback.bind(idx))
		new_entry.pressed.connect(language_selected)
		language_options.append(new_entry)
		directory.add_child(new_entry)
		idx += 1
	if language_options.size() > 0:
		for i in language_options.size():
			var lo : Button = language_options[i]
			var prev_index = clampi(i - 1, 0, language_options.size() - 1)
			var prev_lo : Button = language_options[prev_index]
			var next_index = clampi(i + 1, 0, language_options.size() - 1)
			var next_lo : Button = language_options[next_index]
			lo.set_focus_neighbor(SIDE_TOP, prev_lo.get_path())
			lo.set_focus_neighbor(SIDE_BOTTOM, next_lo.get_path())
			lo.set_focus_neighbor(SIDE_LEFT, self.get_path())
			lo.set_focus_neighbor(SIDE_RIGHT, self.get_path())
	directory.remove_child(entry_original)


func language_selected():
	emit_signal("language_selector_finished")


func focus_top():
	print("Focusing on First Entry in Language Options")
	language_options.front().grab_focus()
	scroll.scroll_vertical = 0


func _on_scroll_container_gui_input(event: InputEvent) -> void:
	#print(event)
	if event is InputEventMouseMotion:
		if event.pressure > 0.02 and event.relative != Vector2.ZERO:
			scroll.scroll_vertical -= event.relative.y
