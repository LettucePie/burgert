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
	root.handle_input_locally = false
	portal.handle_input_locally = true
	game.main_menu.refocus()
	rescale()


# Called when the node enters the scene tree for the first time.
func _ready():
	render.texture.viewport_path = portal.get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func _input(event):
	if event is InputEventKey \
	or event is InputEventJoypadButton \
	or event is InputEventJoypadMotion:
		portal.push_input(event, false)


func _on_game_world_render_gui_input(event):
	print(event)
	portal.push_input(event)


func rescale():
	var w = 640
	var h = 480
	var x = get_window().size.x
	var y = get_window().size.y
	var multis = [x / w, y / h]
	var scale_factor = multis.min()
	print("SCALE FACTOR: ", scale_factor)
	if scale_factor == 0 and x >= 320 and y >= 240:
		#render.size = Vector2(320, 240)
		render.scale = Vector2(0.5, 0.5)
		render.position = Vector2.ZERO
	else:
		render.scale = Vector2(scale_factor, scale_factor)
		#render.size = Vector2(w * scale_factor, h * scale_factor)
		render.position.x = (x / 2) - ((w * scale_factor) / 2)
		render.position.y = (y / 2) - ((h * scale_factor) / 2)


func _on_resized():
	rescale()

