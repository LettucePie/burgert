extends Node2D
class_name Munch

@onready var left : AnimatedSprite2D = $left
@onready var right : AnimatedSprite2D = $right
var options : Array = ["_1", "_2", "_3"]

var playing : bool = false


func _ready():
	self.hide()
	left.animation_finished.connect(_on_finish.bind(left))
	right.animation_finished.connect(_on_finish.bind(right))


func play():
	self.show()
	playing = true
	left.play("crumble" + options.pick_random())
	right.play("crumble" + options.pick_random())


func stop():
	playing = false
	self.hide()
	left.stop()
	right.stop()


func _on_finish(side : AnimatedSprite2D):
	if playing:
		side.play("crumble" + options.pick_random())
