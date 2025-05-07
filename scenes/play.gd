extends Node
class_name Play

@export var game_scene : Game
@export var main_menu : MainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_main_menu_start_play():
	get_tree().paused = false


func _on_game_game_paused():
	get_tree().paused = true
	main_menu.set_state(MainMenu.SCREENS.PAUSE)


func _on_main_menu_resume_play():
	get_tree().paused = false
