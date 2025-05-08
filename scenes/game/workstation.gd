extends Area2D
class_name Workstation

@export var ingredient : String = "Lettuce"
@onready var ingredient_sprite : Sprite2D = $sprite/ingredient_sprite
var tick : int = 60
var down : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	tick -= 1
	if tick <= 0:
		tick = 60
		if down:
			down = false
			ingredient_sprite.position.y -= 2
		else:
			down = true
			ingredient_sprite.position.y += 2
