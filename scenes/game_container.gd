extends Control
class_name GameContainer

var play : Play
@export var portal : SubViewport
@export var render : TextureRect
@export var touch_controls : TouchInputs
@export var touch_gui_lifetime : float = 6.0
@export var touch_gui_lifetime_curve : Curve
var last_touch_time : int = 0


func adopt(game : Play, root : Window):
	print("Game Container adopting Play/Game: ", game, " with root of: ", root)
	play = game
	var mus_progress : float = game.music.get_playback_position()
	root.remove_child(game)
	portal.add_child(game)
	root.content_scale_mode = 0
	root.add_child(self)
	game.music.play(mus_progress)
	root.handle_input_locally = false
	portal.handle_input_locally = true
	game.main_menu.refocus()
	rescale()


# Called when the node enters the scene tree for the first time.
func _ready():
	render.texture.viewport_path = portal.get_path()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var time_msec : int = Time.get_ticks_msec()
	var time_elapsed : float = float(time_msec) - float(last_touch_time)
	time_elapsed = time_elapsed / 1000
	var progress : float = time_elapsed / touch_gui_lifetime
	var curve_percent : float = touch_gui_lifetime_curve.sample(progress)
	touch_controls.modulate.a = curve_percent



func _input(event):
	if event is InputEventKey \
	or event is InputEventJoypadButton \
	or event is InputEventJoypadMotion:
		portal.push_input(event, false)
		pass
	elif event is InputEventScreenTouch \
	or event is InputEventScreenDrag:
		last_touch_time = Time.get_ticks_msec()


func _on_game_world_render_gui_input(event):
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

