extends Control
class_name GameContainer

@export var portal : SubViewport
@export var render : TextureRect
@export var touch_controls : Control


func adopt(game : Play, root : Window):
	print("Game Container adopting Play/Game: ", game, " with root of: ", root)
	root.remove_child(game)
	portal.add_child(game)
	root.add_child(self)


# Called when the node enters the scene tree for the first time.
func _ready():
	render.texture.viewport_path = portal.get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
