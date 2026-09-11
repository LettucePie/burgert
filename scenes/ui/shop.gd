extends Control
class_name Shop

signal close_shop()

var connected : bool = false
var connect_stage : int = 0
var music_library : Music = null

@onready var main : Control = $phone/main
@onready var finished : Button = $phone/main/menu_0_0/finished
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var connection_label : Label = $phone/connection/label
@export var connection_messages : PackedStringArray = [
	"connecting",
	"connected!",
	"welcome to\n\nGLORBAZON"
]

var menus : Array[VBoxContainer] = []
@onready var intro_menu : VBoxContainer = $phone/main/menu_0_0
enum MENU_BRANCH {MAIN, MUSIC, DECOR, CLOTHING}
enum MUSIC_BRANCH {MAIN, STORE, PLAYLIST, EDITOR}

var primary_branch : MENU_BRANCH = MENU_BRANCH.MAIN
var submenu_branch : int = -1

var current_song_idx : int = 0
var current_song : Song = null
var editing_playlist_name : String = "name"
var editing_playlist : PackedInt32Array = []

###
### Multi-Lang
###
func set_glorbazon_sequence(strings : Array):
	connection_messages.clear()
	for s in strings:
		if s is String:
			connection_messages.append(s)
###
###
###


func _ready() -> void:
	menus.clear()
	for child in main.get_children():
		if child.name.contains("menu"):
			menus.append(child)


func open_shop():
	connected = false
	connect_stage = 0
	anim.play("connect")
	await get_tree().create_timer(randf_range(1.8, 3.2)).timeout
	anim.play("connected")
	load_in_menu(0, 0)
	#main.show()
	#finished.grab_focus()


func update_connection_stage():
	connect_stage += 1
	if connect_stage <= 2:
		connection_label.text = connection_messages[connect_stage]
	else:
		finished.grab_focus()


func _on_finished_pressed() -> void:
	emit_signal("close_shop")


func _tween_center() -> void:
	self.position = Vector2(0, randf_range(2, 4))
	self.rotation = randf_range(-0.03, 0.03)
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", Vector2.ZERO, 0.2)
	tween.set_parallel()
	tween.tween_property(self, "rotation", 0.0, 0.1)
	


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up") \
	or Input.is_action_just_pressed("down") \
	or Input.is_action_just_pressed("confirm") \
	or Input.is_action_just_pressed("cancel"):
		_tween_center()


func load_in_menu(main_idx : int, branch_idx : int) -> void:
	print("Loading Menu: ", main_idx, "_", branch_idx)
	primary_branch = 0
	submenu_branch = 0
	for menu in menus:
		menu.hide()
		if menu.name == "menu_" + str(main_idx) + "_" + str(branch_idx):
			menu.show()
			menu.grab_focus()
			primary_branch = main_idx
			submenu_branch = branch_idx
	if primary_branch == 0:
		intro_menu.show()
	if primary_branch == 1:
		if submenu_branch == 1 or submenu_branch == 3:
			current_song_idx = 0
			_render_song(current_song_idx)


func _prev_next_song(dir : int) -> void:
	current_song_idx += dir
	var library_max : int = music_library.all_songs.size() - 1
	if submenu_branch == 3:
		library_max = music_library.owned_songs.size() - 1
	if current_song_idx < 0:
		current_song_idx = library_max
	elif current_song_idx > library_max:
		current_song_idx = 0
	_render_song(current_song_idx)


func _render_song(idx : int) -> void:
	current_song = music_library.all_songs[idx]
	if submenu_branch == 1:
		$phone/main/menu_1_1/song_label.text = current_song.title + "\n" + current_song.artist
		$phone/main/menu_1_1/purchase.show()
		$phone/main/menu_1_1/purchase.text = "$" + str(current_song.store_cost)
		$phone/main/menu_1_1/owned.hide()
		if music_library.owned_songs.has(idx):
			$phone/main/menu_1_1/purchase.hide()
			$phone/main/menu_1_1/owned.show()
	if submenu_branch == 3:
		var owned_idx : int = music_library.owned_songs[idx]
		current_song = music_library.all_songs[owned_idx]
		$phone/main/menu_1_3/song_label.text = current_song.title + "\n" + current_song.artist
		$phone/main/menu_1_3/toggle.button_pressed = editing_playlist.has(owned_idx)


func _on_purchase_pressed() -> void:
	print("Purchasing Current Song")


func _on_preview_pressed() -> void:
	pass # Replace with function body.


func _on_toggle_pressed() -> void:
	var toggle : bool = $phone/main/menu_1_3/toggle.button_pressed
	music_library.playlist_edit(editing_playlist_name, current_song, toggle)
	_playlist_load(editing_playlist_name)


func _playlist_load(playlist_name: String) -> void:
	print("Playlist Load")
	if playlist_name == "work":
		$phone/main/menu_1_3/playlist_label.text = $phone/main/menu_1_2/work_playlist.text
		editing_playlist = music_library.play_playlist.duplicate()
	if playlist_name == "menu":
		$phone/main/menu_1_3/playlist_label.text = $phone/main/menu_1_2/main_playlist.text
		editing_playlist = music_library.main_playlist.duplicate()
	if playlist_name == "jukebox":
		$phone/main/menu_1_3/playlist_label.text = $phone/main/menu_1_2/jukebox_playlist.text
		editing_playlist = music_library.jukebox_playlist.duplicate()
	editing_playlist_name = playlist_name


func _focusing_my_brains_out(path: String) -> void:
	var target : Control = get_node(path)
	if target.get_parent().visible:
		target.grab_focus()
		print("path: ", path, " FOCUS")
