extends Node
class_name Game

func _process(delta):
	if Input.is_action_just_pressed("menu"):
		print("PAUSE")
