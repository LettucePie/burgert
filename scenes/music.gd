extends AudioStreamPlayer
class_name Music


@export var menu : AudioStreamMP3
@export var tracks : Array[AudioStreamMP3]
@onready var anim : AnimationPlayer = $anim

enum STATE {MENU, PLAY, PAUSE}
var current_state : STATE = STATE.MENU

var playback_time : float = -0


func set_state(new_state : STATE):
	if new_state == STATE.MENU:
		anim.play("intro_ramp")
	if new_state == STATE.PLAY:
		if current_state == STATE.MENU:
			anim.play("start_play")
		if current_state == STATE.PAUSE:
			if playback_time >= 0:
				play(playback_time)
			anim.play("resume_play")
	if new_state == STATE.PAUSE:
		if current_state == STATE.PLAY:
			playback_time = -1
			anim.play("pause_play")
	current_state = new_state


func set_track_random():
	var options = tracks.duplicate()
	if options.has(stream):
		options.erase(stream)
	stream = options.pick_random()
	play()


func _on_finished():
	anim.play("queue_next")


func capture_playback_time():
	playback_time = get_playback_position()
	stop()
