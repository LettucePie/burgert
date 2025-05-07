extends Node
class_name Game

signal game_paused()

func _process(delta):
	if Input.is_action_just_pressed("menu"):
		print("PAUSE")
		emit_signal("game_paused")
