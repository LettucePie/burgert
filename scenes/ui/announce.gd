extends Control
class_name Announce

signal announce_finish()

@onready var schedule : Schedule = Schedule.new()
@onready var day_label : Label = $Control/Day
@onready var message_label : Label = $Control/Message
@onready var anim : AnimationPlayer = $AnimationPlayer

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
## Multi Lang
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
	
	var announce_style : String = "_" + str(randi_range(0, 1))
	anim.play("announce" + announce_style)


func _ready() -> void:
	set_day_message()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print("ANNOUNCE FINISHED")
	emit_signal("announce_finish")
