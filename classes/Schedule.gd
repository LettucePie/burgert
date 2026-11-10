extends Resource
class_name Schedule

const MORNING_START = 4
const NOON_START = 10
const AFTERNOON_START = 14
const MIDNIGHT_START = 22

class TimeSlot:
	var weekday_a : Time.Weekday = Time.WEEKDAY_SUNDAY
	var time_a : int = 0
	var weekday_b : Time.Weekday = Time.WEEKDAY_SATURDAY
	var time_b : int = 24

	func _init(wa : Time.Weekday, ta : int, wb : Time.Weekday, tb : int) -> void:
		weekday_a = wa
		time_a = ta
		weekday_b = wb
		time_b = tb


var time_chart : Array[TimeSlot] = [
	TimeSlot.new(0, 0, 6, 24), ## ALL Time
	TimeSlot.new(0, MORNING_START, 0, NOON_START), ## Sunday Morning
	TimeSlot.new(0, NOON_START, 0, AFTERNOON_START), ## Sunday Noon
	TimeSlot.new(0, AFTERNOON_START, 0, MIDNIGHT_START), ## Sunday Night
	TimeSlot.new(0, MIDNIGHT_START, 1, MORNING_START), ## Sunday Midnight
	TimeSlot.new(1, MORNING_START, 1, NOON_START), ## Monday Morning
	TimeSlot.new(1, NOON_START, 1, AFTERNOON_START),
	TimeSlot.new(1, AFTERNOON_START, 1, MIDNIGHT_START),
	TimeSlot.new(1, MIDNIGHT_START, 2, MORNING_START),
	TimeSlot.new(2, MORNING_START, 2, NOON_START), ## Tuesday Morning
	TimeSlot.new(2, NOON_START, 2, AFTERNOON_START),
	TimeSlot.new(2, AFTERNOON_START, 2, MIDNIGHT_START),
	TimeSlot.new(2, MIDNIGHT_START, 3, MORNING_START),
	TimeSlot.new(3, MORNING_START, 3, NOON_START), ## Wednesday Morning
	TimeSlot.new(3, NOON_START, 3, AFTERNOON_START),
	TimeSlot.new(3, AFTERNOON_START, 3, MIDNIGHT_START),
	TimeSlot.new(3, MIDNIGHT_START, 4, MORNING_START),
	TimeSlot.new(4, MORNING_START, 4, NOON_START), ## Thursday Morning
	TimeSlot.new(4, NOON_START, 4, AFTERNOON_START),
	TimeSlot.new(4, AFTERNOON_START, 4, MIDNIGHT_START),
	TimeSlot.new(4, MIDNIGHT_START, 5, MORNING_START),
	TimeSlot.new(5, MORNING_START, 5, NOON_START), ## Friday Morning
	TimeSlot.new(5, NOON_START, 5, AFTERNOON_START),
	TimeSlot.new(5, AFTERNOON_START, 5, MIDNIGHT_START),
	TimeSlot.new(5, MIDNIGHT_START, 6, MORNING_START),
	TimeSlot.new(6, MORNING_START, 6, NOON_START), ## Saturday Morning
	TimeSlot.new(6, NOON_START, 6, AFTERNOON_START),
	TimeSlot.new(6, AFTERNOON_START, 6, MIDNIGHT_START),
	TimeSlot.new(6, MIDNIGHT_START, 0, MORNING_START),
]

var same_day_groups : Array = [
	[1, 2, 3, 4],     ## SUNDAY
	[5, 6, 7, 8],     ## MONDAY
	[9, 10, 11, 12],  ## TUESDAY
	[13, 14, 15, 16], ## WEDNESDAY
	[17, 18, 19, 20], ## THURSDAY
	[21, 22, 23, 24], ## FRIDAY
	[25, 26, 27, 28]  ## SATURDAY
]

enum TIMES {
	ANY,
	SUNDAY_MORNING, SUNDAY_NOON, SUNDAY_AFTERNOON, SUNDAY_MIDNIGHT,
	MONDAY_MORNING, MONDAY_NOON, MONDAY_AFTERNOON, MONDAY_MIDNIGHT,
	TUESDAY_MORNING, TUESDAY_NOON, TUESDAY_AFTERNOON, TUESDAY_MIDNIGHT,
	WEDNESDAY_MORNING, WEDNESDAY_NOON, WEDNESDAY_AFTERNOON, WEDNESDAY_MIDNIGHT,
	THURSDAY_MORNING, THURSDAY_NOON, THURSDAY_AFTERNOON, THURSDAY_MIDNIGHT,
	FRIDAY_MORNING, FRIDAY_NOON, FRIDAY_AFTERNOON, FRIDAY_MIDNIGHT,
	SATURDAY_MORNING, SATURDAY_NOON, SATURDAY_AFTERNOON, SATURDAY_MIDNIGHT
}

@export var times : Array[TIMES] = []

var timeslot_segment : Array = [
	MIDNIGHT_START,
	MORNING_START,
	NOON_START,
	AFTERNOON_START,
	MIDNIGHT_START
]


func within_range(w : Time.Weekday, t : int) -> bool:
	var result : bool = false
	for ti in times:
		var ts : TimeSlot = time_chart[ti]
		var midnight : bool = ts.weekday_a != ts.weekday_b
		if (ts.weekday_a == w and t >= ts.time_a) \
		and (ts.weekday_b == w and t < ts.time_b):
			result = true
		elif midnight:
			if (w == ts.weekday_a and t >= ts.time_a) \
			or (w == ts.weekday_b and t < ts.time_b):
				result = true
	return result


func get_current_timeslot() -> int:
	var result = -1
	
	var time = Time.get_datetime_dict_from_system(false)
	var w = time.weekday
	var t = time.hour
	for i in time_chart.size():
		if i > 0:
			var ts : TimeSlot = time_chart[i]
			var midnight : bool = ts.weekday_a != ts.weekday_b
			if (ts.weekday_a == w and t >= ts.time_a) \
			and (ts.weekday_b == w and t < ts.time_b):
				result = i
			elif midnight:
				if (w == ts.weekday_a and t >= ts.time_a) \
				or (w == ts.weekday_b and t < ts.time_b):
					result = i
	
	return result


func get_current_day_group() -> Array:
	var result : Array = same_day_groups[0]
	
	var time = Time.get_datetime_dict_from_system(false)
	result = same_day_groups[time.weekday]
	
	return result
