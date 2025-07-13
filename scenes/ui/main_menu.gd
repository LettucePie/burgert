extends Control
class_name MainMenu

signal start_play()
signal resume_play()
signal quit_play()
signal update_mus_vol(new_val)
signal update_sfx_vol(new_val)
signal update_a_b_swap(new_val)

@export var anim : AnimationPlayer
enum SCREENS{MAIN, OPTIONS, CREDITS, PAUSE}
var current_screen : SCREENS = SCREENS.MAIN


func refocus():
	$Main/Play.call_deferred("grab_focus")


func _ready():
	refocus()


func _process(delta):
	$Main/Quit.visible = OS.has_feature("web") == false


func main_button_event(but):
	print("Button Pressed: ", but)
	if but == "play" and current_screen == SCREENS.MAIN:
		anim.play("play_start")
	if but == "options" and current_screen == SCREENS.MAIN:
		anim.play("options_open")
		current_screen = SCREENS.OPTIONS
		$Options/Panel/VBoxContainer/mus_vol.grab_focus()
	if but == "credits" and current_screen == SCREENS.MAIN:
		anim.play("credits_open")
		current_screen = SCREENS.CREDITS
		$Credits/Panel/VBoxContainer/finished.grab_focus()
	if but == "quit":
		get_tree().quit()


func option_button_event(but):
	print("Button Pressed: ", but)
	if but == "options_done" and current_screen == SCREENS.OPTIONS:
		anim.play("options_close")
		current_screen = SCREENS.MAIN
		$Main/Play.grab_focus()


func credit_button_event(but):
	print("Button Pressed: ", but)
	if but == "credits_done" and current_screen == SCREENS.CREDITS:
		anim.play("credits_close")
		current_screen = SCREENS.MAIN
		$Main/Play.grab_focus()


func pause_button_event(but):
	print("Button Pressed: ", but)
	if but == "resume" and current_screen == SCREENS.PAUSE:
		anim.play("pause_close")
	if but == "quit" and current_screen == SCREENS.PAUSE:
		anim.play("quit_game")
		emit_signal("quit_play")
		$Main/Play.grab_focus()


func set_state(state : SCREENS):
	anim.play("start")
	current_screen = state
	if state == SCREENS.MAIN:
		$Main/Play.grab_focus()
	if state == SCREENS.OPTIONS:
		anim.play("options_open")
	if state == SCREENS.CREDITS:
		anim.play("credits_open")
	if state == SCREENS.PAUSE:
		anim.play("pause_open")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "play_start":
		print("Starting PLAY")
		emit_signal("start_play")
		$Paused/Panel/VBoxContainer/resume.grab_focus()
	if anim_name == "pause_open" and current_screen == SCREENS.PAUSE:
		$Paused/Panel/VBoxContainer/resume.grab_focus()
	if anim_name == "pause_close" and current_screen == SCREENS.PAUSE:
		emit_signal("resume_play")


func _on_mus_vol_update_value(new_val):
	print("Mus Vol Update, new_val: ", new_val)
	emit_signal("update_mus_vol", new_val)


func _on_sfx_vol_update_value(new_val):
	emit_signal("update_sfx_vol", new_val)


func _on_swap_confirm_toggled(toggled_on):
	emit_signal("update_a_b_swap", toggled_on)


func update_settings_display(settings : Play.Settings):
	print("Updating Settings Display")
	$Options/Panel/VBoxContainer/mus_vol.value = settings.get_mus_vol()
	$Options/Panel/VBoxContainer/mus_vol.update_vals(false)
	$Options/Panel/VBoxContainer/sfx_vol.value = settings.get_sfx_vol()
	$Options/Panel/VBoxContainer/sfx_vol.update_vals(false)
	$Options/Panel/VBoxContainer/swap_confirm.button_pressed = settings.get_a_b_swap()
