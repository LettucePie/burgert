extends Node
class_name Play

@export var game_version : int = 1
@export var game_scene : Game
@export var main_menu : MainMenu
##-----------
@export var audio_bus : AudioBusLayout

class Settings:
	var version : int
	var mus_vol : int
	var sfx_vol : int
	var a_b_swap : bool
	
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


var settings : Settings


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


func _ready():
	get_tree().paused = true
	game_scene.stop_game()
	if FileAccess.file_exists("user://settings.json"):
		_load_settings()
	else:
		_default_settings()


func _process(delta):
	pass


func _on_main_menu_start_play():
	get_tree().paused = false
	game_scene.start_game()


func _on_game_game_paused():
	get_tree().paused = true
	main_menu.set_state(MainMenu.SCREENS.PAUSE)


func _on_game_game_finished():
	get_tree().paused = true


func _on_main_menu_resume_play():
	get_tree().paused = false


func _on_main_menu_quit_play():
	get_tree().paused = true
	game_scene.stop_game()


func _on_game_game_over():
	_on_main_menu_quit_play()
	main_menu.set_state(MainMenu.SCREENS.MAIN)


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
	main_menu.update_settings_display(settings)
	var mus_idx : int = AudioServer.get_bus_index("MUS")
	var sfx_idx : int = AudioServer.get_bus_index("SFX")
	var mus_db : float = linear_to_db(float(settings.get_mus_vol()) / 10.0)
	var sfx_db : float = linear_to_db(float(settings.get_sfx_vol()) / 10.0)
	AudioServer.set_bus_volume_db(mus_idx, mus_db)
	AudioServer.set_bus_volume_db(sfx_idx, sfx_db)





