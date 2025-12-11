extends Area2D
class_name Workstation


@export var ingredient : String = "Lettuce"
@export var highlight : Sprite2D = null
@onready var ingredient_sprite : Sprite2D = $ingredient_sprite
var tick : int = 60
var down : bool = false
var runic : bool = false
@export var rune : Rune


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
	if runic:
		rune.highlighted = tf
	else:
		highlight.visible = tf
		if !tf and down:
			down = false
			ingredient_sprite.position.y -= 2


func set_runic(tf : bool):
	runic = tf
	if runic:
		ingredient_sprite.hide()
		rune.show()
	else:
		ingredient_sprite.show()
		rune.hide()
