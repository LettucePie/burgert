extends Node
class_name MenuFlair

@export var splat_vfx : PackedScene

var last_button_splattered : Control = null

func _ready():
	var splat_buttons = get_tree().get_nodes_in_group("splat")
	for sb in splat_buttons:
		sb.focus_entered.connect(splat_button_focused.bind(sb))
		sb.mouse_entered.connect(mouse_focus.bind(sb))


func mouse_focus(control : Control):
	control.grab_focus()


func splat_button_focused(control : Control):
	if last_button_splattered != control:
		var new_splat = splat_vfx.instantiate()
		new_splat.activate_on_target(control)
		last_button_splattered = control
	
