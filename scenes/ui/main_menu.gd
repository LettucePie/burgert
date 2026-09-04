extends Control
class_name MainMenu

signal start_play()
signal resume_play()
signal quit_play()
signal bgm_pause(pause : bool)

@onready var main : MainSandwhich = $Main
@onready var help : Help = $Help
@onready var options : Options = $Options
@onready var customer_dex : CustomerDex = $CustomerDex
@onready var records : Records = $Records
@onready var jukebox : Jukebox = $Jukebox
@onready var menu_flair : MenuFlair = $MenuFlair
@export var anim : AnimationPlayer
enum SCREENS{MAIN, OPTIONS, RECORDS, RADIO, HELP, DEX, CREDITS, PAUSE, SHOP}
var current_screen : SCREENS = SCREENS.MAIN
var queued_menu : SCREENS = SCREENS.MAIN
var left_side_screens : Array[SCREENS] = [
	SCREENS.DEX, SCREENS.RADIO, SCREENS.RECORDS
]
var left_side_commands : PackedStringArray = [
	"Customer-Dex", "Jukebox", "Records", "Shop"
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
	if string_in == "Shop":
		result = SCREENS.SHOP
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
		if queued_menu == SCREENS.RADIO:
			emit_signal("bgm_pause", true)


## TODO Migrate to _on_main_menu_selection
func main_button_event(but):
	print("Button Pressed: ", but)
	if but == "play" and current_screen == SCREENS.MAIN:
		anim.play("play_start")
	if but == "options" and current_screen == SCREENS.MAIN:
		anim.play("options_open")
		current_screen = SCREENS.OPTIONS
		$Options/Panel/VBoxContainer/mus_vol.grab_focus()
	if but == "quit":
		get_tree().quit()


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
## TODO Expand this
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
		elif queued_menu == SCREENS.OPTIONS:
			print("Play Options Open")
			anim.play("options_open")
		elif queued_menu == SCREENS.HELP:
			print("Play Help Open")
			anim.play("help_open")
		elif queued_menu == SCREENS.RADIO:
			print("Play Radio Open")
			anim.play("radio_open")
		elif queued_menu == SCREENS.CREDITS:
			print("Play Credits Open")
			anim.play("credits_open")
		elif queued_menu == SCREENS.SHOP:
			print("Play Shop Open")
			anim.play("shop_open")
		else:
			current_screen = queued_menu
			_return_to_desk_center()
	
	if anim_name.contains("desk_return") and queued_menu == SCREENS.MAIN:
		print("Finished Returning to Center Desk")
		current_screen = queued_menu
	
	if anim_name == "dex_open":
		current_screen = SCREENS.DEX
	if anim_name == "records_open":
		current_screen = SCREENS.RECORDS
	if anim_name == "options_open":
		current_screen = SCREENS.OPTIONS
	if anim_name == "help_open":
		current_screen = SCREENS.HELP
	if anim_name == "radio_open":
		current_screen = SCREENS.RADIO
	if anim_name == "credits_open":
		current_screen = SCREENS.CREDITS
	if anim_name == "shop_open":
		current_screen = SCREENS.SHOP


func _on_customer_dex_close_customerdex() -> void:
	print("Close CustomerDex")
	if current_screen == SCREENS.DEX:
		anim.play("dex_close")
		queued_menu = SCREENS.MAIN


func _on_records_close_records() -> void:
	print("Closing Records...")
	if current_screen == SCREENS.RECORDS:
		anim.play("records_close")
		queued_menu = SCREENS.MAIN


func _on_options_close_options() -> void:
	print("Closing Options...")
	if current_screen == SCREENS.OPTIONS:
		anim.play("options_close")
		queued_menu = SCREENS.MAIN


func _on_help_close_pressed() -> void:
	print("Closing Help...")
	if current_screen == SCREENS.HELP:
		anim.play("help_close")
		queued_menu = SCREENS.MAIN


func _on_jukebox_stop_pressed() -> void:
	print("Closing Radio... or Jukebox... or whatever i cannot decide on")
	if current_screen == SCREENS.RADIO:
		anim.play("radio_close")
		queued_menu = SCREENS.MAIN
		emit_signal("bgm_pause", false)


func _on_credits_close_credits() -> void:
	print("Closing Credits...")
	if current_screen == SCREENS.CREDITS:
		anim.play("credits_close")
		queued_menu = SCREENS.MAIN


func _on_shop_close_shop() -> void:
	print("Closing Shop...")
	if current_screen == SCREENS.SHOP:
		anim.play("shop_close")
		queued_menu = SCREENS.MAIN
