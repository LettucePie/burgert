extends Control

@export var anim : AnimationPlayer
enum SCREENS{MAIN, OPTIONS, CREDITS}
var current_screen : SCREENS = SCREENS.MAIN

# Called when the node enters the scene tree for the first time.
func _ready():
	$Main/Play.call_deferred("grab_focus")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func main_button_event(but):
	print("Button Pressed: ", but)
	if but == "options" and current_screen == SCREENS.MAIN:
		anim.play("options_open")
		current_screen = SCREENS.OPTIONS
		$Options/Panel/VBoxContainer/mus_vol.grab_focus()
		$Options/Panel/VBoxContainer/mus_vol.grab_click_focus()
		


func option_button_event(but):
	print("Button Pressed: ", but)
	if but == "options_done" and current_screen == SCREENS.OPTIONS:
		anim.play("options_close")
		current_screen = SCREENS.MAIN
		$Main/Play.grab_focus()
