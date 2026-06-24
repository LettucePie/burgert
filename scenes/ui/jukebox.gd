extends Control
class_name Jukebox

signal stop_pressed()

@export var track_files : Array[AudioStreamMP3] = []
@export var track_titles : PackedStringArray = [
	"break", "burgert 1", "burgert 2", "burgert 3", "BurgerFlippin'", "alphabetprimenumber"
]
var current_track : int = 0
var current_playback : float = 0
var current_volume : int = 5
var looping : bool = false
var shuffling : bool = false
var play_order : Array = []
@onready var player : AudioStreamPlayer = $Player
@onready var track_label : Label = $screen/track_title
@onready var jukebox_progress : JukeboxProgress = $screen/progress
@onready var jukebox_vol : SliderInputIconOnly = $jukebox_vol
@onready var track_timer : Timer = $track_time
##
##
@onready var play_button : TextureButton = $controls/play
@onready var play_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_play.png")
@onready var play_highlight_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_play_highlight.png")
@onready var pause_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_pause.png")
@onready var pause_highlight_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_pause_highlight.png")
@onready var loop_button : TextureButton = $loop
@onready var loop_on_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/loop_on.png")
@onready var loop_on_highlight : Texture = preload("res://assets/images/graphics/menu/jukebox/loop_on_hover.png")
@onready var loop_off_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/loop_off.png")
@onready var loop_off_highlight : Texture = preload("res://assets/images/graphics/menu/jukebox/loop_off_hover.png")
@onready var shuffle_button : TextureButton = $shuffle
@onready var shuffle_on_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/shuffle_on.png")
@onready var shuffle_on_highlight : Texture = preload("res://assets/images/graphics/menu/jukebox/shuffle_on_hover.png")
@onready var shuffle_off_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/shuffle_off.png")
@onready var shuffle_off_highlight : Texture = preload("res://assets/images/graphics/menu/jukebox/shuffle_off_hover.png")



func ready_jukebox() -> void:
	player.stop()
	current_track = 0
	looping = false
	shuffling = false
	_build_play_order(shuffling)
	_update_player()
	play_button.grab_focus()
	jukebox_vol.value = current_volume
	jukebox_vol.update_vals(true)


func _ready() -> void:
	if get_window().get_child(0) == self:
		ready_jukebox()


func _build_play_order(shuffled : bool):
	play_order = []
	for i in track_files.size():
		play_order.append(i)
	if shuffled:
		play_order.shuffle()


func _on_prev_pressed() -> void:
	current_track -= 1
	if current_track < 0:
		current_track = track_files.size() - 1
	_update_player()
	jukebox_progress.reset_progress()


func _update_play_button() -> void:
	var normal : Texture = play_texture
	var highlight : Texture = play_highlight_texture
	if player.playing:
		normal = pause_texture
		highlight = pause_highlight_texture
	play_button.texture_normal = normal
	play_button.texture_pressed = highlight
	play_button.texture_hover = highlight
	play_button.texture_focused = highlight


func _update_loop_button() -> void:
	var normal : Texture = loop_off_texture
	var highlight : Texture = loop_off_highlight
	if looping:
		normal = loop_on_texture
		highlight = loop_on_highlight
	loop_button.texture_normal = normal
	loop_button.texture_pressed = highlight
	loop_button.texture_hover = highlight
	loop_button.texture_focused = highlight


func _update_shuffle_button() -> void:
	var normal : Texture = shuffle_off_texture
	var highlight : Texture = shuffle_off_highlight
	if shuffling:
		normal = shuffle_on_texture
		highlight = shuffle_on_highlight
	shuffle_button.texture_normal = normal
	shuffle_button.texture_pressed = highlight
	shuffle_button.texture_hover = highlight
	shuffle_button.texture_focused = highlight


func _on_play_pressed() -> void:
	print("Play Pressed")
	#_update_player()
	if player.playing:
		player.stop()
		track_timer.paused = true
	else:
		player.play(current_playback)
		if track_timer.paused:
			track_timer.paused = false
		else:
			track_timer.start()
	_update_play_button()


func _on_next_pressed() -> void:
	current_track += 1
	if current_track > track_files.size() - 1:
		current_track = 0
	_update_player()
	jukebox_progress.reset_progress()


func _on_stop_pressed() -> void:
	print("Stop Pressed")
	player.stop()
	track_timer.stop()
	#_update_progress()
	#current_playback = 0
	emit_signal("stop_pressed")


func _update_player() -> void:
	var idx : int = play_order[current_track]
	player.stream = track_files[idx]
	track_label.text = str(idx + 1) + " - " + track_titles[idx]
	track_timer.wait_time = track_files[idx].get_length()
	track_timer.paused = false
	current_playback = 0
	_update_play_button()
	_update_loop_button()
	_update_shuffle_button()


func _update_progress() -> void:
	var max : float = player.stream.get_length()
	current_playback = max - track_timer.time_left
	var progress : float = current_playback / max
	var current_digitized : int = ceili(progress * 28)
	jukebox_progress.set_progress(current_digitized)
	if max - current_playback <= 0.1:
		_on_player_finished()


func _physics_process(delta: float) -> void:
	if player.playing:
		_update_progress()


func _on_jukebox_vol_update_value(new_val: Variant) -> void:
	player.volume_db = linear_to_db(new_val / 10.0)


func _on_loop_pressed() -> void:
	if looping:
		looping = false
	else:
		looping = true
	_update_loop_button()


func _on_shuffle_pressed() -> void:
	if shuffling:
		shuffling = false
		if play_order.size() > 0:
			current_track = play_order[current_track]
	else:
		shuffling = true
	_update_shuffle_button()
	_build_play_order(shuffling)


func _on_player_finished() -> void:
	track_timer.stop()
	if looping:
		player.stop()
		current_playback = 0.0
		_update_player()
		player.play()
		track_timer.start()
		_update_play_button()
	else:
		_on_next_pressed()
		player.play()
		track_timer.start()
		_update_play_button()
