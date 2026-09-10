extends Control
class_name Announce

@onready var schedule : Schedule = Schedule.new()

var announce_messages : PackedStringArray = [
	
]

##
## Multi Lang
##
func set_announce_messages(strings : Array) -> void:
	announce_messages.clear()
	for s in strings:
		if s is String:
			announce_messages.append(s)


func _ready() -> void:
	var timeslot : int = schedule.get_current_timeslot()
