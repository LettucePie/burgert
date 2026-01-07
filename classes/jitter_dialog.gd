extends Node
class_name JitterDialog

@onready var player = get_parent()
@export var jitter_box : Array[AudioStreamWAV] = []
var toggled : bool = false
var interval : int = 100
var interval_trace : int = -1


func _ready():
	player.set_bus("SFX")


func _process(delta: float) -> void:
	if toggled:
		var ticks = Time.get_ticks_msec()
		if ticks > interval_trace:
			jitter()
			interval_trace = ticks + interval


func toggle_jitter(on_off : bool):
	toggled = on_off
	if toggled:
		interval_trace = Time.get_ticks_msec() + interval
		randomize()


func set_interval(val : int):
	interval = val


func jitter():
	if jitter_box.size() > 0:
		player.stream = jitter_box.pick_random()
		player.pitch_scale = randf_range(0.77, 1.455)
		player.play()
