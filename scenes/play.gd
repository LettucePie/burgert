extends Node
class_name Play

@export var game_scene : Game
@export var main_menu : MainMenu


func _ready():
	get_tree().paused = true


func _process(delta):
	pass


func _on_main_menu_start_play():
	get_tree().paused = false
	game_scene.start_game()


func _on_game_game_paused():
	get_tree().paused = true
	main_menu.set_state(MainMenu.SCREENS.PAUSE)


func _on_main_menu_resume_play():
	get_tree().paused = false


func _on_main_menu_quit_play():
	get_tree().paused = true
