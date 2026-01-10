extends Control

@onready var stack : Array = $Sandwhich.get_children()
var current_stack : int = 0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_stack = stack.size() - 1 


func _tween_layer_in(obj : Sprite2D):
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(obj, "position", Vector2.ZERO, 0.2)
	var rot_target = randf_range(PI * -0.05, PI * 0.05)
	tween.set_parallel()
	tween.tween_property(obj, "rotation", rot_target, 0.3)


func _tween_layer_out(obj : Sprite2D):
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(obj, "position", Vector2(0, 300), 0.2)
	var rot_target = PI
	if randi_range(0, 1) > 0:
		rot_target *= -1
	tween.set_parallel()
	tween.tween_property(obj, "rotation", rot_target, 0.3)


func _adjust_stack(arg : int):
	print("Adjusting Stack from: ", current_stack, " by: ", arg)
	var layer : Sprite2D = stack[current_stack]
	if arg < 0:
		_tween_layer_out(layer)
	elif arg > 0:
		_tween_layer_in(layer)
	current_stack = clamp(current_stack + arg, 0, stack.size() - 1)


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_DOWN:
				_adjust_stack(-1)
			elif event.keycode == KEY_UP:
				_adjust_stack(1)
