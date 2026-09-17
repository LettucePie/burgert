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
var container : GameContainer = null
var adopted : bool = false

####
#### Settings Block
####

class Settings:
	var version : int
	var mus_vol : int
	var sfx_vol : int
	var a_b_swap : bool
	var mode_3d : bool
	var language : String
	
	var keys : Array = ["version", "mus_vol", "sfx_vol", "a_b_swap", "mode_3d", "language"]
	
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
	
	func set_mode_3d(new : bool):
		mode_3d = new
	
	func get_mode_3d() -> bool:
		return mode_3d
	
	func set_language(new : String):
		language = new
	
	func get_language() -> String:
		return language

var settings : Settings
@onready var default_confirm_events : Array[InputEvent] = InputMap.action_get_events("confirm")
@onready var default_cancel_events : Array[InputEvent] = InputMap.action_get_events("cancel")


func _default_settings():
	print("Loading Default Settings")
	settings = Settings.new()
	settings.version = game_version
	settings.set_mus_vol(8)
	settings.set_sfx_vol(8)
	settings.set_a_b_swap(false)
	if OS.has_feature("portmaster"):
		settings.set_mode_3d(false)
	else:
		settings.set_mode_3d(true)
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
			settings.set_mode_3d(data["mode_3d"])
			settings.set_language(data["language"])
	apply_settings()


func _save_settings():
	print("Saving Settings")
	var settings_dict : Dictionary = {
		"version" = game_version,
		"mus_vol" = settings.get_mus_vol(),
		"sfx_vol" = settings.get_sfx_vol(),
		"a_b_swap" = settings.get_a_b_swap(),
		"mode_3d" = settings.get_mode_3d(),
		"language" = settings.get_language()
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


func apply_settings():
	print("APPLYING SETTINGS TO GAME")
	main_menu.options.set_host(self)
	main_menu.options.apply_settings()
	var mus_idx : int = AudioServer.get_bus_index("MUS")
	var sfx_idx : int = AudioServer.get_bus_index("SFX")
	var mus_db : float = linear_to_db(float(settings.get_mus_vol()) / 10.0)
	var sfx_db : float = linear_to_db(float(settings.get_sfx_vol()) / 10.0)
	AudioServer.set_bus_volume_db(mus_idx, mus_db)
	AudioServer.set_bus_volume_db(sfx_idx, sfx_db)
	music.max_volume_db = mus_db
	InputMap.action_erase_events("confirm")
	InputMap.action_erase_events("cancel")
	var confirm_target : String = "confirm"
	var cancel_target : String = "cancel"
	if settings.get_a_b_swap():
		confirm_target = "cancel"
		cancel_target = "confirm"
	game_scene.burger_mode_3d = settings.get_mode_3d()
	for ie in default_confirm_events:
		InputMap.action_add_event(confirm_target, ie)
		if confirm_target == "confirm":
			InputMap.action_add_event("ui_accept", ie)
	for ie in default_cancel_events:
		InputMap.action_add_event(cancel_target, ie)
		if cancel_target == "confirm":
			InputMap.action_add_event("ui_accept", ie)
	multi_lang.load_lang(settings.get_language())

####
#### End Settings Block
####
####
#### Stats Block
####

class Stats:
	var version : int
	var highest_score : int = 0
	var times_played : int = 0
	var total_score : int = 0
	var spent_score : int = 0
	var timeslots_played : PackedInt32Array = []
	var songs_owned : PackedInt32Array = []
	var play_playlist : PackedInt32Array = []
	var main_playlist : PackedInt32Array = []
	var jukebox_playlist : PackedInt32Array = []
	
	var keys : Array = [
		"version", "highest_score", "times_played", "total_score",
		"spent_score", "timeslots_played", 
		"songs_owned", "play_playlist", "main_playlist", "jukebox_playlist",
		"customer_stats"
	]
	
	var customers_in_kitchen : Array[Customer] = []
	
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
		if new > 0:
			total_score += new
	
	func get_highest_score() -> int:
		return highest_score
	
	func set_total_score(new : int):
		total_score = new
	
	func get_total_score() -> int:
		return total_score
	
	func set_spent_score(new : int):
		spent_score = new
	
	func get_spent_score() -> int:
		return spent_score
	
	func adjust_spent_score(arg : int):
		spent_score += arg
	
	func set_times_played(new : int):
		times_played = new
	
	func get_times_played() -> int:
		return times_played
	
	func add_times_played() -> void:
		times_played += 1
	
	func set_timeslots_played(new : Array) -> void:
		timeslots_played = new
	
	func get_timeslots_played() -> PackedInt32Array:
		return timeslots_played
	
	func add_timeslot_played(timeslot_idx : int) -> void:
		if !timeslots_played.has(timeslot_idx):
			timeslots_played.append(timeslot_idx)
	
	func set_songs_owned(new : Array) -> void:
		songs_owned = new
	
	func get_songs_owned() -> PackedInt32Array:
		return songs_owned
	
	func add_song_owned(song_idx : int) -> void:
		if !songs_owned.has(song_idx):
			songs_owned.append(song_idx)
	
	func set_play_playlist(new : Array) -> void:
		play_playlist = new
	
	func get_play_playlist() -> PackedInt32Array:
		return play_playlist
	
	func set_main_playlist(new : Array) -> void:
		main_playlist = new
	
	func get_main_playlist() -> PackedInt32Array:
		return main_playlist
	
	func set_jukebox_playlist(new : Array) -> void:
		jukebox_playlist = new
	
	func get_jukebox_playlist() -> PackedInt32Array:
		return jukebox_playlist
	
	func set_customer_stats(new : Array[CustomerStat]):
		customer_stats = new
	
	func get_customer_stats() -> Array[CustomerStat]:
		return customer_stats
	
	func set_customer_stats_from_dict(list : Array):
		customer_stats.clear()
		for data in list:
			var new_customer_stat : CustomerStat = CustomerStat.new()
			new_customer_stat.customer_name = data["customer_name"]
			new_customer_stat.set_orders_served(data["orders_served"])
			new_customer_stat.set_fantastic_orders(data["fantastic_orders"])
			new_customer_stat.set_satisfactory_orders(data["satisfactory_orders"])
			new_customer_stat.set_disappointing_orders(data["disappointing_orders"])
			customer_stats.append(new_customer_stat)
	
	func get_customer_stats_as_dict() -> Array:
		var result : Array = []
		for cs in customer_stats:
			result.append({
				"customer_name" : cs.customer_name,
				"orders_served" : cs.get_orders_served(),
				"fantastic_orders" : cs.get_fantastic_orders(),
				"satisfactory_orders" : cs.get_satisfactory_orders(),
				"disappointing_orders" : cs.get_disappointing_orders()
			})
		return result
	
	func fetch_customerstat(customer_name : String) -> CustomerStat:
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


func _default_stats():
	stats = Stats.new()
	stats.set_songs_owned([2, 3, 5, 8, 11, 12])
	stats.set_play_playlist([3, 5, 11])
	stats.set_main_playlist([2, 8, 12])
	stats.set_jukebox_playlist([2, 3, 5, 8, 11, 12])
	_save_stats()


func _update_stats(old_data, old_version):
	if old_version == 1:
		print("migrate old data to new data, save, reload")


func _load_stats():
	var stats_file = FileAccess.open("user://burgert.sav", FileAccess.READ)
	print("Stats File Opened")
	if stats == null:
		stats = Stats.new()
	var valid = true
	while stats_file.get_position() < stats_file.get_length():
		var json_string = stats_file.get_line()
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
			print("Stats Load :: Version Mismatch")
			_update_stats(data, data["version"])
		for k in stats.keys:
			if !data.has(k):
				valid = false
		if !valid:
			print("Stats Load :: Keys Missing")
		if valid:
			stats.set_highest_score(data["highest_score"])
			stats.set_times_played(data["times_played"])
			stats.set_total_score(data["total_score"])
			stats.set_spent_score(data["spent_score"])
			stats.set_timeslots_played(data["timeslots_played"])
			stats.set_songs_owned(data["songs_owned"])
			stats.set_play_playlist(data["play_playlist"])
			stats.set_main_playlist(data["main_playlist"])
			stats.set_jukebox_playlist(data["jukebox_playlist"])
			stats.set_customer_stats_from_dict(data["customer_stats"])
	stats.customers_in_kitchen = game_scene.kitchen.customers
	apply_stats()


func _save_stats():
	print("Saving Stats")
	var stats_dict : Dictionary = {
		"version" = game_version,
		"highest_score" = stats.get_highest_score(),
		"times_played" = stats.get_times_played(),
		"total_score" = stats.get_total_score(),
		"spent_score" = stats.get_spent_score(),
		"timeslots_played" = stats.get_timeslots_played(),
		"songs_owned" = stats.get_songs_owned(),
		"play_playlist" = stats.get_play_playlist(),
		"main_playlist" = stats.get_main_playlist(),
		"jukebox_playlist" = stats.get_jukebox_playlist(),
		"customer_stats" = stats.get_customer_stats_as_dict(),
	}
	var stats_file = FileAccess.open("user://burgert.sav", FileAccess.WRITE)
	print(FileAccess.get_open_error())
	var json_string = JSON.stringify(stats_dict)
	stats_file.store_line(json_string)
	print("Saved STATS!")
	apply_stats()


func apply_stats():
	main_menu.customer_dex.assign_stats(stats)
	main_menu.records.assign_stats(stats)
	music.owned_songs = stats.get_songs_owned()
	music.play_playlist = stats.get_play_playlist()
	music.main_playlist = stats.get_main_playlist()
	music.jukebox_playlist = stats.get_jukebox_playlist()


####
#### End Stats Block
####

func _ready():
	get_tree().paused = true
	game_scene.stop_game(false)
	if FileAccess.file_exists("user://settings.json"):
		_load_settings()
	else:
		_default_settings()
	if FileAccess.file_exists("user://burgert.sav"):
		_load_stats()
	else:
		_default_stats()
	if OS.has_feature("portmaster"):
		_clear_joypad_inputs()
	if OS.has_feature("mobile") and !adopted:
		container = container_scene.instantiate()
		container.call_deferred("adopt", self, get_tree().get_root())
		adopted = true
		main_menu.customer_dex.assign_viewport(container.portal)
	multi_lang.call_deferred("introduce_language_selector", main_menu.options.language_selector)
	main_menu.customer_dex.extract_schedules(stats.customers_in_kitchen)
	main_menu.jukebox.music_library = music
	main_menu.shop.wallet = stats
	main_menu.shop.music_library = music


func _process(delta):
	pass


func _input(event):
	if event is InputEventScreenTouch and !adopted:
		var container : GameContainer = container_scene.instantiate()
		container.call_deferred("adopt", self, get_tree().get_root())
		adopted = true
		main_menu.help.input_mode = 2
	if event is InputEventKey:
		if OS.has_feature("portmaster"):
			main_menu.help.input_mode = 1
		else:
			main_menu.help.input_mode = 0
	if event is InputEventJoypadButton:
		main_menu.help.input_mode = 1
	if event is InputEventKey and OS.has_feature("editor"):
		if event.keycode == KEY_F1 and event.is_pressed():
			for customer in game_scene.kitchen.customers:
				for i in 10:
					_on_game_finished_order(customer.customer_name, 3)


func _on_main_menu_prepare_kitchen() -> void:
	music.anim.play("pause_play")
	game_scene.kitchen.prep_kitchen()


func _on_main_menu_start_play():
	get_tree().paused = false
	game_scene.start_game()
	music.set_state(Music.STATE.PLAY)


func _on_game_game_paused():
	get_tree().paused = true
	main_menu.set_state(MainMenu.SCREENS.PAUSE)
	music.set_state(Music.STATE.PAUSE)


func _on_game_game_finished(final_score : int):
	get_tree().paused = true
	stats.add_times_played()
	stats.set_highest_score(final_score)
	stats.add_timeslot_played(game_scene.kitchen.kitchen_timeslot)
	_save_stats()
	#music.set_state(Music.STATE.MENU)


func _on_game_finished_order(customer_name: String, satisfaction_rank: int) -> void:
	var customer_stats : Stats.CustomerStat = stats.fetch_customerstat(customer_name)
	customer_stats.add_orders_served()
	if satisfaction_rank == 1:
		customer_stats.add_disappointing_orders()
	elif satisfaction_rank == 2:
		customer_stats.add_satisfactory_orders()
	elif satisfaction_rank == 3:
		customer_stats.add_fantastic_orders()
	_save_stats()


func _on_main_menu_resume_play():
	get_tree().paused = false
	music.set_state(Music.STATE.PLAY)


func _on_main_menu_quit_play():
	game_scene.stop_game(true)
	music.set_state(Music.STATE.MENU)
	get_tree().paused = true


func _on_game_game_over():
	main_menu.anim.play("quit_game")
	_on_main_menu_quit_play()


func options_update_mus_vol(new_val):
	if settings != null:
		settings.set_mus_vol(new_val)
		_save_settings()


func options_update_sfx_vol(new_val):
	if settings != null:
		settings.set_sfx_vol(new_val)
		_save_settings()


func options_update_a_b_swap(new_val):
	if settings != null:
		settings.set_a_b_swap(new_val)
		_save_settings()


func options_update_mode_3d(new_val):
	if settings != null:
		settings.set_mode_3d(new_val)
		_save_settings()


func _on_multi_lang_set_lang(lang: String) -> void:
	if settings != null:
		settings.set_language(lang)
		_save_settings()


func _on_main_menu_bgm_pause(pause: bool) -> void:
	if pause:
		music.anim.play("pause_play")
	else:
		music.anim.play("resume_play")
		music.play(music.playback_time)


func _on_music_purchased_song(song: Song) -> void:
	stats.add_song_owned(music.all_songs.find(song))
	stats.adjust_spent_score(song.store_cost)
	_save_stats()


func _on_music_updated_playlists() -> void:
	_save_stats()
