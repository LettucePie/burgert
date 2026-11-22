extends Node2D
class_name QuestCutscenes

@onready var anim_scene : AnimationPlayer = $AnimationPlayer
@onready var space : Sprite2D = $space
##
@onready var anim_text : AnimationPlayer = $Control/AnimationPlayer
@onready var profile_picture_left : TextureRect = $Control/Panel/profile_bg_L/profile_picture_L
@onready var dialog_left : Label = $Control/Panel/dialog_L
@onready var profile_picture_right : TextureRect = $Control/Panel/profile_bg_R/profile_picture_R
@onready var dialog_right : Label = $Control/Panel/dialog_R
@onready var announce_label : Label = $Control/center_shade/announce

var page : int = -1
var scene_playwrite : PackedStringArray = [
	"scene_1",
	"hold",
	"hold",
	"hold",
	"scene_2"
]
var text_playwrite : PackedStringArray = [
	"pause_mid",
	"text_1",
	"text_2",
	"text_3",
	"text_4"
]
var announces : PackedStringArray = [
	"",
	"Once Upon a normal afternoon shift..."
]
var dialogs : PackedStringArray = [
	"",
	"Gramps: Has anyone seen the mayo? I don't normally like it but I’ve got the taste for it.",
	"Gramps: Oh there it is..."
]
var text_finished : bool = false
var text_speed : float = 1.0


func _ready() -> void:
	page = -1
	advance_page()


func advance_page() -> void:
	print("Advance Page")
	page += 1
	text_finished = false
	text_speed = 1.0
	if scene_playwrite[page].contains("scene"):
		anim_scene.play(scene_playwrite[page])
	anim_text.play(text_playwrite[page])


func finish_text_pause() -> void:
	text_finished = true
	text_speed = 1.0


func _process_text() -> void:
	anim_text.speed_scale = text_speed
	if Input.is_action_just_pressed("confirm") \
	or Input.is_action_just_pressed("cancel") \
	or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if !text_finished:
			text_speed += 0.5
		else:
			advance_page()


func _process(delta: float) -> void:
	space.region_rect.position.x += delta
	_process_text()


func populate_announce(idx : int) -> void:
	announce_label.text = announces[idx]


func populate_dialog(box : String, idx : int) -> void:
	if box == "Left":
		dialog_left.text = dialogs[idx]
	elif box == "Right":
		dialog_right.text = dialogs[idx]


func _on_anim_text_finished(anim_name: StringName) -> void:
	text_speed = 1.0
	text_finished = true
