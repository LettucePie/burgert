extends Node3D

@onready var camdoll : Node3D = $CamDoll
@onready var stack : Array = $Sandwhich.get_children()
var current_stack : int = 0

var start_poses : PackedVector3Array
var removed_poses : PackedVector3Array



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_stack = stack.size() - 1 
	start_poses = []
	removed_poses = []
	for s in stack:
		var offset : Vector3 = s.position
		start_poses.append(offset)
		offset.z = 10
		removed_poses.append(offset)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in stack.size():
		if i > current_stack:
			stack[i].position = stack[i].position.move_toward(removed_poses[i], 0.5)
		else:
			stack[i].position = stack[i].position.move_toward(start_poses[i], 0.5)


func _adjust_stack(arg : int):
	print("Adjusting Stack from: ", current_stack, " by: ", arg)
	current_stack = clamp(current_stack + arg, 0, stack.size() - 1)
	


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			if event.keycode == KEY_DOWN:
				_adjust_stack(-1)
			elif event.keycode == KEY_UP:
				_adjust_stack(1)
