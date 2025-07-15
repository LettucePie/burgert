extends Node
class_name MenuFlair

@export var splat_buttons : Array[Control]

@export var splat_vfx : PackedScene

var last_button_splattered : Control = null

func _ready():
	for sb in splat_buttons:
		sb.focus_entered.connect(splat_button_focused.bind(sb))


func splat_button_focused(control : Control):
	if last_button_splattered != control:
		var new_splat = splat_vfx.instantiate()
		new_splat.activate_on_target(control)
		last_button_splattered = control
	
