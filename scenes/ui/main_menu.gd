extends Control
class_name MainMenu

signal start_play()
signal resume_play()
signal quit_play()
signal update_mus_vol(new_val)
signal update_sfx_vol(new_val)
signal update_a_b_swap(new_val)

@onready var main : MainSandwhich = $Main
@onready var help : Help = $Help
@onready var customer_dex : CustomerDex = $CustomerDex
@onready var records : Records = $Records
@onready var menu_flair : MenuFlair = $MenuFlair
@onready var language_selector : LanguageSelector = $LanguageSelector
@export var anim : AnimationPlayer
enum SCREENS{MAIN, OPTIONS, LANG, RECORDS, RADIO, HELP, DEX, CREDITS, PAUSE}
var current_screen : SCREENS = SCREENS.MAIN
var queued_menu : SCREENS = SCREENS.MAIN
var left_side_screens : Array[SCREENS] = [
	SCREENS.DEX, SCREENS.RADIO, SCREENS.RECORDS
]
var left_side_commands : PackedStringArray = [
	"Customer-Dex", "Jukebox", "Records"
]
var right_side_screens : Array[SCREENS] = [
	SCREENS.CREDITS, SCREENS.OPTIONS, SCREENS.HELP
]
var right_side_commands : PackedStringArray = [
	"Credits", "Options", "Help"
]


func refocus():
	main.call_deferred("grab_focus")
	main.go_to_layer("")
	if OS.has_feature("web"):
		print("Make WEB Version of Sandwhich")


func _ready():
	refocus()

## Why tho?
## at this point should just use the string as the memory point...
func screen_string_to_enum(string_in : String) -> SCREENS:
	var result := SCREENS.MAIN
	if string_in == "Customer-Dex":
		result = SCREENS.DEX
	if string_in == "Jukebox":
		result = SCREENS.RADIO
	if string_in == "Records":
		result = SCREENS.RECORDS
	if string_in == "Credits":
		result = SCREENS.CREDITS
	if string_in == "Options":
		result = SCREENS.OPTIONS
	if string_in == "Help":
		result = SCREENS.HELP
	return result


func _on_main_menu_selection(selection: String) -> void:
	if current_screen == SCREENS.MAIN:
		if selection == "Play":
			anim.play("play_start")
		elif selection == "Quit":
			print("Quit")
			get_tree().quit()
		elif left_side_commands.has(selection):
			print("Pan Left: ", selection)
			queued_menu = screen_string_to_enum(selection)
			anim.play("desk_pan_left")
		elif right_side_commands.has(selection):
			print("Pan Right: ", selection)
			queued_menu = screen_string_to_enum(selection)
			anim.play("desk_pan_right")


## TODO Migrate to _on_main_menu_selection
func main_button_event(but):
	print("Button Pressed: ", but)
	if but == "play" and current_screen == SCREENS.MAIN:
		anim.play("play_start")
	if but == "options" and current_screen == SCREENS.MAIN:
		anim.play("options_open")
		current_screen = SCREENS.OPTIONS
		$Options/Panel/VBoxContainer/mus_vol.grab_focus()
	#if but == "extras" and current_screen == SCREENS.MAIN:
		#anim.play("extras_open")
		#current_screen = SCREENS.EXTRAS
		#$Extras/Panel/VBoxContainer/button_row/howto.grab_focus()
	if but == "quit":
		get_tree().quit()


func option_button_event(but):
	print("Button Pressed: ", but)
	if but == "lang_select" and current_screen == SCREENS.OPTIONS:
		anim.play("lang_select_open")
		current_screen = SCREENS.LANG
		language_selector.focus_top()
	if but == "options_done" and current_screen == SCREENS.OPTIONS:
		anim.play("options_close")
		current_screen = SCREENS.MAIN
		main.go_to_layer("Options")


#func extras_button_event(but):
	#print("Button Pressed: ", but)
	#if but == "howto" and current_screen == SCREENS.EXTRAS:
		#anim.play("help_open")
		#current_screen = SCREENS.HELP
		#$Help/Controls/next.grab_focus()
		#help.start_page()
	#if but == "dex" and current_screen == SCREENS.EXTRAS:
		#anim.play("customerdex_open")
		#current_screen = SCREENS.DEX
		#$CustomerDex/controls/done.grab_focus()
		#customer_dex.open_dex()
	#if but == "credits" and current_screen == SCREENS.EXTRAS:
		#anim.play("credits_open")
		#current_screen = SCREENS.CREDITS
		#$Credits/Panel/VBoxContainer/finished.grab_focus()
	#if but == "finish" and current_screen == SCREENS.EXTRAS:
		#anim.play("extras_close")
		#current_screen = SCREENS.MAIN
		#print("REPLACE EXTRAS SCREEN")


func help_button_event(but):
	print("Button Pressed: ", but)
	if but == "close_help" and current_screen == SCREENS.HELP:
		anim.play("help_close")
		#current_screen = SCREENS.EXTRAS
		$Extras/Panel/VBoxContainer/button_row/howto.grab_focus()


func credit_button_event(but):
	print("Button Pressed: ", but)
	if but == "credits_done" and current_screen == SCREENS.CREDITS:
		anim.play("credits_close")
		#current_screen = SCREENS.EXTRAS
		$Extras/Panel/VBoxContainer/button_row3/credits.grab_focus()


func pause_button_event(but):
	print("Button Pressed: ", but)
	if but == "resume" and current_screen == SCREENS.PAUSE:
		anim.play("pause_close")
	if but == "quit" and current_screen == SCREENS.PAUSE:
		anim.play("quit_game")
		#anim.play("play_stop")
		emit_signal("quit_play")
		main.go_to_layer("Play")


## For instant overriding menu access
func set_state(state : SCREENS):
	anim.play("start")
	current_screen = state
	if state == SCREENS.MAIN:
		main.grab_focus()
		main.go_to_layer("Play")
	if state == SCREENS.OPTIONS:
		anim.play("options_open")
	if state == SCREENS.CREDITS:
		anim.play("credits_open")
	if state == SCREENS.PAUSE:
		anim.play("pause_open")


func _return_to_desk_center():
	if current_screen != SCREENS.MAIN:
		var target_anim := "desk_return_left"
		if right_side_screens.has(current_screen):
			target_anim = "desk_return_right"
		queued_menu = SCREENS.MAIN
		anim.play(target_anim)


func _on_animation_player_animation_finished(anim_name : String):
	if anim_name == "play_start":
		print("Starting PLAY")
		emit_signal("start_play")
		$Paused/Panel/VBoxContainer/resume.grab_focus()
	if anim_name == "pause_open" and current_screen == SCREENS.PAUSE:
		$Paused/Panel/VBoxContainer/resume.grab_focus()
	if anim_name == "pause_close" and current_screen == SCREENS.PAUSE:
		emit_signal("resume_play")
	if anim_name.contains("desk_pan") and queued_menu != SCREENS.MAIN:
		print("Finished Panning, now play bonus animation")
		if queued_menu == SCREENS.DEX:
			print("Play Dex Screen open.")
			anim.play("dex_open")
		elif queued_menu == SCREENS.RECORDS:
			print("Play Records Open")
			anim.play("records_open")
		else:
			current_screen = queued_menu
			_return_to_desk_center()
	
	if anim_name.contains("desk_return") and queued_menu == SCREENS.MAIN:
		print("Finished Returning to Center Desk")
		current_screen = queued_menu
	
	if anim_name == "dex_open":
		current_screen = SCREENS.DEX


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


func _on_language_selector_language_selector_finished() -> void:
	print("Language Selector is finished")
	if current_screen == SCREENS.LANG:
		anim.play("lang_select_close")
		current_screen = SCREENS.OPTIONS
		$Options/Panel/VBoxContainer/set_lang.grab_focus()


func _on_customerdex_done_pressed() -> void:
	print("Close CustomerDex")
	if current_screen == SCREENS.DEX:
		anim.play("dex_close")
		queued_menu = SCREENS.MAIN
