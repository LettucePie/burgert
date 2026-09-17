extends Control
class_name Announce

signal announce_finish()

@onready var schedule : Schedule = Schedule.new()
@onready var day_label : Label = $Control/Day
@onready var message_label : Label = $Control/Message
@onready var anim : AnimationPlayer = $AnimationPlayer

@onready var day_audio : AudioStreamPlayer2D = $Control/Day/day_audio
@onready var message_audio : AudioStreamPlayer2D = $Control/Message/message_audio
@export var typewriter_sounds : Array[AudioStreamWAV] = []
@export var burn_sound : AudioStreamWAV = null

var current_announcement : int = -1
var day_character_visible : int = -1
var message_character_visible : int = -1

var day : PackedStringArray = [
	"SUNDAY",
	"MONDAY",
	"TUESDAY",
	"WEDNESDAY",
	"THURSDAY",
	"FRIDAY",
	"SATURDAY"
]
var announce_slots : Array = [
	[0, 1, 2, 3], ## Night
	[4, 5, 6, 7], ## Morning
	[8, 9, 10, 11], ## Noon
	[12, 13, 14, 15], ## Afternoon
	[0, 1, 2, 3] ## Night Again
]
var announce_messages : PackedStringArray = [
	"A dark eerie night", ## Night
	"Crisp midnight air",
	"Feeding the Late-night munchies",
	"Cooling off under the moon",
	"Early Bird gets the Burger", ## Morning
	"A bustling morning",
	"Warming up with the dew",
	"Damp with coffee",
	"Lunch rush special", ## Noon
	"Brightest and Hottest hour",
	"Mid-Day sun",
	"Noon already?",
	"Simmering down now", ## Afternoon
	"Heat dropping, Sun setting",
	"All in a days work",
	"Good afternoon"
]

##
## Multi-Lang
##
func set_day(strings : Array) -> void:
	day.clear()
	for s in strings:
		if s is String:
			day.append(s)

func set_announce_messages(strings : Array) -> void:
	announce_messages.clear()
	for s in strings:
		if s is String:
			announce_messages.append(s)
##
## Multi-lang Eng
##


func set_day_message() -> void:
	var timeslot : int = schedule.get_current_timeslot()
	var day_idx : int = 0
	for idx in schedule.same_day_groups.size():
		if schedule.same_day_groups[idx].has(timeslot):
			day_idx = idx
	day_label.text = day[day_idx]
	var message_idx = announce_slots[timeslot % 4].pick_random()
	message_label.text = announce_messages[message_idx]
	self.show()
	current_announcement = randi_range(0, 2)
	var announce_style : String = "_" + str(current_announcement)
	anim.play("announce" + announce_style)


func _ready() -> void:
	pass


func _announcement_sfx() -> void:
	if current_announcement == 0: ## Typewriter Announcement
		if day_label.visible_characters != day_character_visible:
			day_audio.stream = typewriter_sounds.pick_random()
			day_audio.play()
			day_character_visible = day_label.visible_characters
		if message_label.visible_characters != message_character_visible:
			message_audio.stream = typewriter_sounds.pick_random()
			message_audio.play()
			message_character_visible = message_label.visible_characters


func _process(delta: float) -> void:
	if anim.is_playing():
		_announcement_sfx()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	current_announcement = -1
	emit_signal("announce_finish")
	self.hide()
