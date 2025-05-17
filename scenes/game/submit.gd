extends Node2D
class_name Submit

const SPEED = 700
@export var x_min : float = 10
@export var x_max : float = 630
@onready var target : Node2D = $crosshair


var playing : bool = false
var travel : int = 1


func _ready():
	self.hide()


func _physics_process(delta):
	if playing:
		var new_pos = target.position.x
		new_pos += (SPEED * delta) * travel
		new_pos = clamp(new_pos, x_min, x_max)
		target.position.x = new_pos
		if new_pos >= x_max:
			travel = -1
		elif new_pos <= x_min:
			travel = 1


func set_playing(tf : bool):
	playing = tf
	visible = tf
	if tf:
		target.position.x = x_min
		travel = 1
	
