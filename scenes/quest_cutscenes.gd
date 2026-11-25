extends Node2D
class_name QuestCutscenes

signal exit_cutscene(idx)

@onready var anim_scene : AnimationPlayer = $AnimationPlayer
@onready var space : Sprite2D = $space
##
@onready var anim_text : AnimationPlayer = $Control/AnimationPlayer
@onready var profile_picture_left : TextureRect = $Control/Panel/profile_bg_L/profile_picture_L
@onready var dialog_left : Label = $Control/Panel/dialog_L
@onready var profile_picture_right : TextureRect = $Control/Panel/profile_bg_R/profile_picture_R
@onready var dialog_right : Label = $Control/Panel/dialog_R
@onready var announce_label : Label = $Control/center_shade/announce
@onready var audio_L : AudioStreamPlayer2D = $Control/Panel/profile_bg_L/audio_L
@onready var audio_R : AudioStreamPlayer2D = $Control/Panel/profile_bg_R/audio_R
@export var voice_libary : Array[AudioStreamWAV] = []
@onready var voice_banks : Array[PackedInt32Array] = [
	[0, 1],
]
var current_voice_bank_L : int = 0
var current_voice_bank_R : int = 1
##
var scene_id : int = -1
var page : int = -1
var scene_playwrite : PackedStringArray = [
	"scene_1",
	"hold",
	"hold",
	"hold",
	"scene_2",
	"scene_3",
	"scene_4",
	"scene_5",
	"hold",
	"hold",
	"scene_6", ## Fade Black
	"scene_7", ## Reveal Hospital
	"scene_8", ## Enter Chef
	"scene_9", ## Grampa starts talking
	"hold",
	"hold",
	"hold",
	"hold",
	"hold",
	"hold",
	"scene_10", ## Grampa snores
	"hold", ## Grampa Stops
	"scene_11", ## Chef equip and leave
	"exit",
	"scene_12", ## Purple Shroud over everything (Victory Scene)
	"scene_13", ## Reveal Kitchen Scene
	"scene_14", ## Enter Chef and Gramps behind
	"hold",
	"scene_15", ## Lights Flicker
	"scene_16", ## Lights off, customers sneak in
	"scene_17", ## Lights On reveal (Grandiose)
	"scene_18", ## Congrats Message
	"exit"
]
var text_playwrite : PackedStringArray = [
	"pause_mid",
	"text_1",
	"text_2",
	"text_3",
	"text_4",
	"text_5",
	"text_6",
	"text_7",
	"text_8",
	"pause_long", ## Sit on Ambulance
	"pause_long", ## Fade Black
	"pause_long",
	"pause_mid",
	"text_9", ## Grampa in bed
	"text_10",
	"text_11",
	"text_12",
	"text_13",
	"text_14",
	"text_15",
	"text_16", ## Grampa Snoring
	"text_17", ## Finish Grampa dialog
	"pause_hold", ## Chef equip
	"exit",
	"pause_mid", ## Start Victory Scene
	"pause_mid", ## Reveal Kitchen
	"pause_long", ## Enter Chef and Gramps
	"text_18", ## Dialog
	"pause_long", ## lights flickering
	"text_19", ## Dialog about power bill. customers enter shadowed. hide text at end
	"pause_long", ## Reveal
	"text_20", ## Thank Player
	"exit" ##Somehow get to credits at this point.
]
var announces : PackedStringArray = [
	"",
	"Once Upon a normal afternoon shift...",
	"Thanks for playing"
]
var dialogs : PackedStringArray = [
	"",
	"Gramps: Has anyone seen the mayo? I don't normally like it but I’ve got the taste for it.",
	"Gramps: Oh there it is...",
	"Gramps: Can't read the date on here anymore...",
	"Gramps: *sniff sniff*",
	"Gramps: OH WELL!",
	"Gramps: Oh hey ya lil bugger... ya lil... burger...",
	"Gramps: Listen, I need you to run my restaurant for me while I recover from that horrible mayo botulism... ya burgerr.",
	"Gramps: I’ll live! Thats the good news... ",
	"Gramps: The bad news is that this drained my savings. (I may have gambled a lot of money while on all these meds.)",
	"Gramps: So! That’s why you’re here ya lil burgger. You gotta go serve my regulars, the regulars pay to keep the lights on!",
	"Gramps: Oh! And protect my stash! Those bookies will send robot burgorls for what’s left of my money!",
	"Gramps: I know you will do well. You can use the radio, just don’t spend all of the money on your music! Ya sneaky lil bug-... burg-...",
	"Gramps: My lil burgert... take... the mayo... off the menu...",
	"Gramps: Well grandson, you really took my generational debt like a champ... I would be doomed without you.",
	"Gramps: Oh right... the power bill- You got to understand, this stuff never ends. The boulder always rolls back down."
]
var text_finished : bool = false
var text_speed : float = 1.0
var space_speed : float = 1.0
var char_count_L : int = 0
var char_count_R : int = 0


func _ready() -> void:
	page = -1
	if get_window().get_child(0) == self:
		print("TESTING")
		play_cutscene(1)
	else:
		hide()


func play_cutscene(id : int) -> void:
	if id == 0:
		page = -1
	if id == 1:
		page = 23
	scene_id = id
	show()
	anim_scene.play("start")
	anim_text.play("start")
	advance_page()


func advance_page() -> void:
	print("Advance Page")
	page += 1
	text_finished = false
	text_speed = 1.0
	char_count_L = 0
	char_count_R = 0
	print("SCENE: ", scene_playwrite[page])
	print("TEXT: ", text_playwrite[page])
	if page <= scene_playwrite.size() - 1 and anim_text.current_animation != "exit":
		if !scene_playwrite[page].contains("hold"):
			print("Running Scene")
			anim_scene.play(scene_playwrite[page])
		anim_text.play(text_playwrite[page])
		print("Running Text")
	else:
		print("PAGEID: ", page, " TOTAL: ", scene_playwrite.size() - 1)
		print(anim_text.current_animation)


func finish_text_pause() -> void:
	text_finished = true
	text_speed = 1.0


func set_space_speed(val : float) -> void:
	space_speed = val


func set_voice_bank(side : String, bank : int) -> void:
	if side == "Left":
		current_voice_bank_L = bank
	if side == "Right":
		current_voice_bank_R = bank


func play_voice(side : String) -> void:
	if side == "Left":
		var bank : PackedInt32Array = voice_banks[current_voice_bank_L]
		var vox = bank[randi_range(0, bank.size() - 1)]
		audio_L.stream = voice_libary[vox]
		audio_L.play()
	if side == "Right":
		var bank : PackedInt32Array = voice_banks[current_voice_bank_R]
		var vox = bank[randi_range(0, bank.size() - 1)]
		audio_R.stream = voice_libary[vox]
		audio_R.play()


func _step_progress() -> void:
	if !text_finished and anim_text.current_animation.contains("text"):
		text_speed += 0.5
	else:
		advance_page()

func _process_text() -> void:
	anim_text.speed_scale = text_speed
	if Input.is_action_just_pressed("confirm") \
	or Input.is_action_just_pressed("cancel"):
		_step_progress()
	if dialog_left.visible:
		if abs(dialog_left.visible_characters - char_count_L) >= 3:
			char_count_L = dialog_left.visible_characters
			play_voice("Left")
	if dialog_right.visible:
		if abs(dialog_right.visible_characters - char_count_R) >= 3:
			char_count_R = dialog_right.visible_characters
			play_voice("Right")


func _process(delta: float) -> void:
	if visible:
		space.region_rect.position.x += space_speed * delta
		_process_text()


func populate_announce(idx : int) -> void:
	announce_label.text = announces[idx]


func populate_dialog(box : String, idx : int) -> void:
	if box == "Left":
		dialog_left.text = dialogs[idx]
	elif box == "Right":
		dialog_right.text = dialogs[idx]


@warning_ignore("unused_parameter")
func _on_anim_text_finished(anim_name: StringName) -> void:
	text_speed = 1.0
	text_finished = true


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == 1:
			_step_progress()


func spread_customers() -> void:
	for c in $kitchen/Node2D.get_children():
		if randf() > 0.5:
			c.position.x = 800
		else:
			c.position.x = -800


func exit_custscene() -> void:
	emit_signal("exit_cutscene", scene_id)
