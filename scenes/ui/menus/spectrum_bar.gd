extends VBoxContainer
class_name SpectrumBar

const THRESHOLD : float = 300.0
var value : float = 0.0
var display_val : float = 0.0
@onready var bars : Array = get_children()
@onready var anim_tree : AnimationTree = $AnimationTree


func update_value(new_val : float) -> void:
	value = clampf(new_val, 0.0, THRESHOLD)
	value = inverse_lerp(0.0, THRESHOLD, value) * 5


func _process(delta: float) -> void:
	var speed : float = 0.26
	if value > display_val:
		speed = 0.38
	display_val = lerpf(display_val, value, speed)
	anim_tree.set("parameters/blend_position", display_val)
