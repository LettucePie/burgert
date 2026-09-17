extends AnimatedSprite2D
var time_next : int = 0


func _process(delta: float) -> void:
	if Time.get_ticks_msec() > time_next:
		play("default")
		time_next = Time.get_ticks_msec() + randi_range(400, 8000)
