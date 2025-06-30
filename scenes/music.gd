extends AudioStreamPlayer
class_name Music


@export var menu : AudioStreamMP3
@export var tracks : Array[AudioStreamMP3]
@export var menu_lq : AudioStreamMP3
@export var tracks_lq : Array[AudioStreamMP3]
@onready var anim : AnimationPlayer = $anim

enum STATE {MENU, PLAY, PAUSE}
var current_state : STATE = STATE.MENU
var web : String = ""


func _ready():
	if OS.has_feature("web"):
		web = "_WEB"
		stream = menu_lq
		anim.play("intro_ramp_WEB")


func set_state(new_state : STATE):
	if new_state == STATE.MENU:
		anim.play("intro_ramp" + web)
	if new_state == STATE.PLAY:
		if current_state == STATE.MENU:
			anim.play("start_play")
		if current_state == STATE.PAUSE:
			anim.play("resume_play")
	if new_state == STATE.PAUSE:
		if current_state == STATE.PLAY:
			anim.play("pause_play")
	current_state = new_state


func set_track_random():
	var options = tracks.duplicate()
	if OS.has_feature("web"):
		options = tracks_lq.duplicate()
	if options.has(stream):
		options.erase(stream)
	stream = options.pick_random()
	play()


func _on_finished():
	anim.play("queue_next")
