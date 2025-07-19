extends Node
class_name Play

@export var game_version : int = 1
@export var game_scene : Game
@export var main_menu : MainMenu
@export var music : Music
@export var multi_lang : MultiLang
##-----------
@export var audio_bus : AudioBusLayout
@export var container_scene : PackedScene
var adopted : bool = false

class Settings:
	var version : int
	var mus_vol : int
	var sfx_vol : int
	var a_b_swap : bool
	var language : String
	
	var keys : Array = ["version", "mus_vol", "sfx_vol", "a_b_swap"]
	
	func set_mus_vol(new : int):
		mus_vol = new
	
	func get_mus_vol() -> int:
		return mus_vol
	
	func set_sfx_vol(new : int):
		sfx_vol = new
	
	func get_sfx_vol() -> int:
		return sfx_vol
	
	func set_a_b_swap(new : bool):
		a_b_swap = new
	
	func get_a_b_swap() -> bool:
		return a_b_swap
	
	func set_language(new : String):
		language = new
	
	func get_language() -> String:
		return language

var settings : Settings
@onready var default_confirm_events : Array[InputEvent] = InputMap.action_get_events("confirm")
@onready var default_cancel_events : Array[InputEvent] = InputMap.action_get_events("cancel")

class Stats:
	var highest_score : int = 0
	var times_played : int = 0
	
	class CustomerStat:
		var customer_name : String
		var orders_served : int
		var fantastic_orders : int
		var satisfactory_orders : int
		var disappointed_orders : int
		
		func set_orders_served(new : int):
			orders_served = new
		
		func get_orders_served() -> int:
			return orders_served
		
		func add_orders_served():
			orders_served += 1
		
		func set_fantastic_orders(new : int):
			fantastic_orders = new
		
		func get_fantastic_orders() -> int:
			return fantastic_orders
		
		func add_fantastic_orders():
			fantastic_orders += 1
		
		func set_satisfactory_orders(new : int):
			satisfactory_orders = new
		
		func get_satisfactory_orders() -> int:
			return satisfactory_orders
		
		func add_satisfactory_orders():
			satisfactory_orders += 1
		
		func set_disappointing_orders(new : int):
			disappointed_orders = new
		
		func get_disappointing_orders() -> int:
			return disappointed_orders
		
		func add_disappointing_orders():
			disappointed_orders += 1
	
	var customer_stats : Array[CustomerStat] = []
	
	func set_highest_score(new : int):
		if new > highest_score:
			highest_score = new
	
	func get_highest_score() -> int:
		return highest_score
	
	func set_times_played(new : int):
		times_played = new
	
	func get_times_played() -> int:
		return times_played
	
	func add_times_played() -> void:
		times_played += 1
	
	func get_customerstat(customer_name : String) -> CustomerStat:
		var result : CustomerStat = null
		for cs in customer_stats:
			if cs.customer_name == customer_name:
				result = cs
		if result == null:
			result = CustomerStat.new()
			result.customer_name = customer_name
			customer_stats.append(result)
		return result


var stats : Stats

func _default_settings():
	settings = Settings.new()
	settings.version = game_version
	settings.set_mus_vol(8)
	settings.set_sfx_vol(8)
	settings.set_a_b_swap(false)
	_save_settings()


func _update_settings(old_data, old_version):
	for i in 3:
		print("INTEGRATE OLD SETTINGS HERE")


func _load_settings():
	var settings_file = FileAccess.open("user://settings.json", FileAccess.READ)
	print("Settings File Opened")
	if settings == null:
		settings = Settings.new()
		settings.version = game_version
	var valid = true
	while settings_file.get_position() < settings_file.get_length():
		var json_string = settings_file.get_line()
		var json = JSON.new()
		var parse = json.parse(json_string)
		if not parse == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", \
					json_string, " at line ", json.get_error_line())
			continue
		var data = json.get_data()
		if data.has("version"):
			if data["version"] != game_version:
				valid = false
		if !valid:
			print("Settings Load :: Version Mismatch")
			_update_settings(data, data["version"])
		for k in settings.keys:
			if !data.has(k):
				valid = false
		if !valid:
			print("Settings Load :: Keys Missing")
		if valid:
			settings.set_mus_vol(data["mus_vol"])
			settings.set_sfx_vol(data["sfx_vol"])
			settings.set_a_b_swap(data["a_b_swap"])
	apply_settings()


func _save_settings():
	print("Saving Settings")
	var settings_dict : Dictionary = {
		"version" = game_version,
		"mus_vol" = settings.get_mus_vol(),
		"sfx_vol" = settings.get_sfx_vol(),
		"a_b_swap" = settings.get_a_b_swap()
	}
	var settings_file = FileAccess.open("user://settings.json", FileAccess.WRITE)
	print(FileAccess.get_open_error())
	var json_string = JSON.stringify(settings_dict)
	settings_file.store_line(json_string)
	print("Saved SETTINGS!")
	apply_settings()


func _clear_joypad_inputs():
	var actions = InputMap.get_actions()
	var events = []
	for a in actions:
		events.append(InputMap.action_get_events(a))
		InputMap.action_erase_events(a)
	for i in actions.size():
		var action = actions[i]
		var action_events = events[i]
		for ae in action_events:
			if ae is InputEventKey:
				InputMap.action_add_event(action, ae)
	for a in actions:
		print(a, " | ", InputMap.action_get_events(a))


func _ready():
	get_tree().paused = true
	game_scene.stop_game()
	if FileAccess.file_exists("user://settings.json"):
		_load_settings()
	else:
		_default_settings()
	if OS.has_feature("portmaster"):
		_clear_joypad_inputs()
	if OS.has_feature("mobile") and !adopted:
		var container : GameContainer = container_scene.instantiate()
		container.call_deferred("adopt", self, get_tree().get_root())
		adopted = true
	multi_lang.call_deferred("introduce_language_selector", main_menu.language_selector)


func _process(delta):
	pass


func _input(event):
	if event is InputEventScreenTouch and !adopted:
		var container : GameContainer = container_scene.instantiate()
		container.call_deferred("adopt", self, get_tree().get_root())
		adopted = true


func _on_main_menu_start_play():
	get_tree().paused = false
	game_scene.start_game()
	music.set_state(Music.STATE.PLAY)


func _on_game_game_paused():
	get_tree().paused = true
	main_menu.set_state(MainMenu.SCREENS.PAUSE)
	music.set_state(Music.STATE.PAUSE)


func _on_game_game_finished():
	get_tree().paused = true
	#music.set_state(Music.STATE.MENU)


func _on_main_menu_resume_play():
	get_tree().paused = false
	music.set_state(Music.STATE.PLAY)


func _on_main_menu_quit_play():
	get_tree().paused = true
	game_scene.stop_game()
	music.set_state(Music.STATE.MENU)


func _on_game_game_over():
	_on_main_menu_quit_play()
	main_menu.set_state(MainMenu.SCREENS.MAIN)
	music.set_state(Music.STATE.MENU)


func _on_main_menu_update_mus_vol(new_val):
	if settings != null:
		settings.set_mus_vol(new_val)
		_save_settings()


func _on_main_menu_update_sfx_vol(new_val):
	if settings != null:
		settings.set_sfx_vol(new_val)
		_save_settings()


func _on_main_menu_update_a_b_swap(new_val):
	if settings != null:
		settings.set_a_b_swap(new_val)
		_save_settings()


func apply_settings():
	print("APPLYING SETTINGS TO GAME")
	main_menu.update_settings_display(settings)
	var mus_idx : int = AudioServer.get_bus_index("MUS")
	var sfx_idx : int = AudioServer.get_bus_index("SFX")
	var mus_db : float = linear_to_db(float(settings.get_mus_vol()) / 10.0)
	var sfx_db : float = linear_to_db(float(settings.get_sfx_vol()) / 10.0)
	AudioServer.set_bus_volume_db(mus_idx, mus_db)
	AudioServer.set_bus_volume_db(sfx_idx, sfx_db)
	InputMap.action_erase_events("confirm")
	InputMap.action_erase_events("cancel")
	var confirm_target : String = "confirm"
	var cancel_target : String = "cancel"
	if settings.get_a_b_swap():
		confirm_target = "cancel"
		cancel_target = "confirm"
	for ie in default_confirm_events:
		InputMap.action_add_event(confirm_target, ie)
		if confirm_target == "confirm":
			InputMap.action_add_event("ui_accept", ie)
	for ie in default_cancel_events:
		InputMap.action_add_event(cancel_target, ie)
		if cancel_target == "confirm":
			InputMap.action_add_event("ui_accept", ie)
