extends Area2D
class_name Workstation


@export var ingredient : String = "Lettuce"
@export var highlight : Sprite2D = null
@onready var ingredient_sprite : Sprite2D = $sprite/ingredient_sprite
var tick : int = 60
var down : bool = false



func _ready():
	if highlight == null:
		highlight = get_node("sprite/ingredient_sprite/highlight")
	set_highlight(false)



func _physics_process(delta):
	if highlight.visible:
		tick -= 3
	if tick <= 0:
		tick = 60
		if down:
			down = false
			ingredient_sprite.position.y -= 2
		else:
			down = true
			ingredient_sprite.position.y += 2


func set_highlight(tf : bool):
	highlight.visible = tf
	if !tf and down:
		down = false
		ingredient_sprite.position.y -= 2
