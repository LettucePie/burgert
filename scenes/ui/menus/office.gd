extends Control
class_name Office

@onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass
	#$Timer.start(randf_range(20, 40))


func summon_randoms() -> void:
	pass
	#var anims : Array = Array(anim.get_animation_list())
	#anim.play(anims.pick_random())


func _on_timer_timeout() -> void:
	pass
	#summon_randoms()
	#$Timer.stop()
	#$Timer.start(randf_range(20, 40))
