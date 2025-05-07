extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vec : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"): move_vec.x -= 1
	if Input.is_action_pressed("right"): move_vec.x += 1
	position.x += move_vec.x * delta
