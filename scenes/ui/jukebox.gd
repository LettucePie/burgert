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
@onready var player : AudioStreamPlayer = $Player
@onready var track_label : Label = $screen/track_title
@onready var jukebox_progress : JukeboxProgress = $screen/progress
@onready var jukebox_vol : SliderInputIconOnly = $jukebox_vol
##
##
@onready var play_button : TextureButton = $controls/play
@onready var play_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_play.png")
@onready var play_highlight_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_play_highlight.png")
@onready var pause_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_pause.png")
@onready var pause_highlight_texture : Texture = preload("res://assets/images/graphics/menu/jukebox/jukebox_interface_pause_highlight.png")


func ready_jukebox() -> void:
	player.stop()
	current_track = 0
	_update_player()
	play_button.grab_focus()
	jukebox_vol.value = current_volume
	jukebox_vol.update_vals(true)


func _ready() -> void:
	if get_window().get_child(0) == self:
		ready_jukebox()


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


func _on_play_pressed() -> void:
	print("Play Pressed")
	#_update_player()
	if player.playing:
		player.stop()
	else:
		player.play(current_playback)
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
	emit_signal("stop_pressed")


func _update_player() -> void:
	player.stream = track_files[current_track]
	track_label.text = str(current_track + 1) + " - " + track_titles[current_track]
	current_playback = 0
	_update_play_button()


func _update_progress() -> void:
	var max : float = player.stream.get_length()
	current_playback = player.get_playback_position()
	var progress : float = current_playback / max
	var current_digitized : int = ceili(progress * 28)
	jukebox_progress.set_progress(current_digitized)


func _process(delta: float) -> void:
	if player.playing:
		_update_progress()


func _on_jukebox_vol_update_value(new_val: Variant) -> void:
	player.volume_db = linear_to_db(new_val / 10.0)
