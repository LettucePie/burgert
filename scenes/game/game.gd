extends Node
class_name Game

signal game_paused()

@export var kitchen : Node2D
@export var hud : Control
@export var chef : Chef
#@export var chef_scene : PackedScene
var game_started : bool = false


func _process(delta):
	if Input.is_action_just_pressed("menu"):
		print("PAUSE")
		emit_signal("game_paused")


func start_game():
	game_started = true
	chef.current_burger.refresh_plate()
