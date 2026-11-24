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
	TimeSlot.new(Time.WEEKDAY_SUNDAY, 0, Time.WEEKDAY_SATURDAY, 24), ## ALL Time
	TimeSlot.new(Time.WEEKDAY_SUNDAY, MORNING_START, Time.WEEKDAY_SUNDAY, NOON_START), ## Sunday Morning
	TimeSlot.new(Time.WEEKDAY_SUNDAY, NOON_START, Time.WEEKDAY_SUNDAY, AFTERNOON_START), ## Sunday Noon
	TimeSlot.new(Time.WEEKDAY_SUNDAY, AFTERNOON_START, Time.WEEKDAY_SUNDAY, MIDNIGHT_START), ## Sunday Night
	TimeSlot.new(Time.WEEKDAY_SUNDAY, MIDNIGHT_START, Time.WEEKDAY_MONDAY, MORNING_START), ## Sunday Midnight
	TimeSlot.new(Time.WEEKDAY_MONDAY, MORNING_START, Time.WEEKDAY_MONDAY, NOON_START), ## Monday Morning
	TimeSlot.new(Time.WEEKDAY_MONDAY, NOON_START, Time.WEEKDAY_MONDAY, AFTERNOON_START),
	TimeSlot.new(Time.WEEKDAY_MONDAY, AFTERNOON_START, Time.WEEKDAY_MONDAY, MIDNIGHT_START),
	TimeSlot.new(Time.WEEKDAY_MONDAY, MIDNIGHT_START, Time.WEEKDAY_TUESDAY, MORNING_START),
	TimeSlot.new(Time.WEEKDAY_TUESDAY, MORNING_START, Time.WEEKDAY_TUESDAY, NOON_START), ## Tuesday Morning
	TimeSlot.new(Time.WEEKDAY_TUESDAY, NOON_START, Time.WEEKDAY_TUESDAY, AFTERNOON_START),
	TimeSlot.new(Time.WEEKDAY_TUESDAY, AFTERNOON_START, Time.WEEKDAY_TUESDAY, MIDNIGHT_START),
	TimeSlot.new(Time.WEEKDAY_TUESDAY, MIDNIGHT_START, Time.WEEKDAY_WEDNESDAY, MORNING_START),
	TimeSlot.new(Time.WEEKDAY_WEDNESDAY, MORNING_START, Time.WEEKDAY_WEDNESDAY, NOON_START), ## Wednesday Morning
	TimeSlot.new(Time.WEEKDAY_WEDNESDAY, NOON_START, Time.WEEKDAY_WEDNESDAY, AFTERNOON_START),
	TimeSlot.new(Time.WEEKDAY_WEDNESDAY, AFTERNOON_START, Time.WEEKDAY_WEDNESDAY, MIDNIGHT_START),
	TimeSlot.new(Time.WEEKDAY_WEDNESDAY, MIDNIGHT_START, Time.WEEKDAY_THURSDAY, MORNING_START),
	TimeSlot.new(Time.WEEKDAY_THURSDAY, MORNING_START, Time.WEEKDAY_THURSDAY, NOON_START), ## Thursday Morning
	TimeSlot.new(Time.WEEKDAY_THURSDAY, NOON_START, Time.WEEKDAY_THURSDAY, AFTERNOON_START),
	TimeSlot.new(Time.WEEKDAY_THURSDAY, AFTERNOON_START, Time.WEEKDAY_THURSDAY, MIDNIGHT_START),
	TimeSlot.new(Time.WEEKDAY_THURSDAY, MIDNIGHT_START, Time.WEEKDAY_FRIDAY, MORNING_START),
	TimeSlot.new(Time.WEEKDAY_FRIDAY, MORNING_START, Time.WEEKDAY_FRIDAY, NOON_START), ## Friday Morning
	TimeSlot.new(Time.WEEKDAY_FRIDAY, NOON_START, Time.WEEKDAY_FRIDAY, AFTERNOON_START),
	TimeSlot.new(Time.WEEKDAY_FRIDAY, AFTERNOON_START, Time.WEEKDAY_FRIDAY, MIDNIGHT_START),
	TimeSlot.new(Time.WEEKDAY_FRIDAY, MIDNIGHT_START, Time.WEEKDAY_SATURDAY, MORNING_START),
	TimeSlot.new(Time.WEEKDAY_SATURDAY, MORNING_START, Time.WEEKDAY_SATURDAY, NOON_START), ## Saturday Morning
	TimeSlot.new(Time.WEEKDAY_SATURDAY, NOON_START, Time.WEEKDAY_SATURDAY, AFTERNOON_START),
	TimeSlot.new(Time.WEEKDAY_SATURDAY, AFTERNOON_START, Time.WEEKDAY_SATURDAY, MIDNIGHT_START),
	TimeSlot.new(Time.WEEKDAY_SATURDAY, MIDNIGHT_START, Time.WEEKDAY_SUNDAY, MORNING_START),
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
