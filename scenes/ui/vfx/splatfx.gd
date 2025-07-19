extends Node
class_name SplatFX

@onready var timer : Timer = $Timer
@onready var sfx : AudioStreamPlayer = $AudioStreamPlayer
@export var lifetime_seconds : float = 0.2
@export var curve : Curve
@export var splat_sounds : Array[AudioStreamWAV]
var target : Control
var start_pos : Vector2
var options : Array[Vector2] = [
	Vector2(2, 1),
	Vector2(-1, 1),
	Vector2(0, -2),
	Vector2(1, 3),
	Vector2(0, 4)
]
var chosen_target : Vector2


func activate_on_target(t : Control):
	target = t
	var splatting : SplatFX = null
	for c in target.get_children():
		if c is SplatFX:
			splatting = c
	if splatting != null:
		splatting.dethrone()
	target.add_child(self)
	start_pos = target.position
	chosen_target = options.pick_random() + start_pos
	sfx.stream = splat_sounds.pick_random()
	sfx.play()
	timer.wait_time = lifetime_seconds
	timer.start()


func _process(delta):
	var elapsed = lifetime_seconds - timer.time_left
	var percent = curve.sample(elapsed / lifetime_seconds)
	target.position = lerp(start_pos, chosen_target, percent)


func _on_timer_timeout() -> void:
	timer.stop()
	target.position = start_pos
	self.queue_free()


func dethrone():
	target.position = start_pos
	self.queue_free()
