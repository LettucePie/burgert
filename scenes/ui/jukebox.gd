extends Control
class_name Jukebox

@export var track_files : Array[AudioStreamMP3] = []
@export var track_titles : PackedStringArray = [
	"break", "burgert 1", "burgert 2", "burgert 3", "BurgerFlippin'", "alphabetprimenumber"
]
var current_track : int = 0
var playback : AudioStreamPlayback
@onready var player : AudioStreamPlayer = $Player
@onready var track_label : Label = $screen/track_title
@onready var jukebox_progress : JukeboxProgress = $screen/progress



func _ready() -> void:
	if get_window().get_child(0) == self:
		$controls/prev.grab_focus()
	player.stream = track_files[current_track]


func _on_prev_pressed() -> void:
	current_track -= 1
	if current_track < 0:
		current_track = track_files.size() - 1
	_update_player()


func _on_play_pressed() -> void:
	print("Play Pressed")
	_update_player()
	#player.play()
	player.playing = true


func _on_next_pressed() -> void:
	current_track += 1
	if current_track > track_files.size() - 1:
		current_track = 0
	_update_player()


func _on_stop_pressed() -> void:
	print("Stop Pressed")


func _update_player() -> void:
	player.stream = track_files[current_track]
	track_label.text = str(current_track + 1) + " - " + track_titles[current_track]


func _update_progress() -> void:
	var max : float = player.stream.get_length()
	var current : float = player.get_playback_position()
	#var max_digitized : int = max / 28
	var progress : float = current / max
	print("max: ", max, " current: ", current, " progress: ", progress)
	var current_digitized : int = ceili(progress * 28)
	jukebox_progress.set_progress(current_digitized)


func _process(delta: float) -> void:
	if player.playing:
		_update_progress()
