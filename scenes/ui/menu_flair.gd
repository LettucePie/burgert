extends Node
class_name MenuFlair

@export var splat_buttons : Array[Control]

@export var splat_vfx : PackedScene

func _ready():
	for sb in splat_buttons:
		sb.focus_entered.connect(splat_button_focused.bind(sb))
	#for wb in wobble_buttons:
		#wb.focus_entered.connect(wobble_button_focused.bind(wb))


func splat_button_focused(control : Control):
	var new_splat = splat_vfx.instantiate()
	new_splat.activate_on_target(control)


func wobble_button_focused(button : Button):
	print("Wobble Button Focused: ", button)
