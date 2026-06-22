extends Resource
class_name Schedule

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
	TimeSlot.new(0, 4, 0, 10), ## Sunday Morning
	TimeSlot.new(0, 10, 0, 14), ## Sunday Noon
	TimeSlot.new(0, 14, 0, 22), ## Sunday Night
	TimeSlot.new(0, 22, 1, 4), ## Sunday Midnight
	TimeSlot.new(1, 4, 1, 10), ## Monday Morning
	TimeSlot.new(1, 10, 1, 14),
	TimeSlot.new(1, 14, 1, 22),
	TimeSlot.new(1, 22, 2, 4),
	TimeSlot.new(2, 4, 2, 10), ## Tuesday Morning
	TimeSlot.new(2, 10, 2, 14),
	TimeSlot.new(2, 14, 2, 22),
	TimeSlot.new(2, 22, 3, 4),
	TimeSlot.new(3, 4, 3, 10), ## Wednesday Morning
	TimeSlot.new(3, 10, 3, 14),
	TimeSlot.new(3, 14, 3, 22),
	TimeSlot.new(3, 22, 4, 4),
	TimeSlot.new(4, 4, 4, 10), ## Thursday Morning
	TimeSlot.new(4, 10, 4, 14),
	TimeSlot.new(4, 14, 4, 22),
	TimeSlot.new(4, 22, 5, 4),
	TimeSlot.new(5, 4, 5, 10), ## Friday Morning
	TimeSlot.new(5, 10, 5, 14),
	TimeSlot.new(5, 14, 5, 22),
	TimeSlot.new(5, 22, 6, 4),
	TimeSlot.new(6, 4, 6, 10), ## Saturday Morning
	TimeSlot.new(6, 10, 6, 14),
	TimeSlot.new(6, 14, 6, 22),
	TimeSlot.new(6, 22, 0, 4),
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

func within_range(w : Time.Weekday, t : int) -> bool:
	var result : bool = false
	for ti in times:
		var ts : TimeSlot = time_chart[ti]
		var midnight : bool = ts.range_a.weekday != ts.range_b.weekday
		if (ts.range_a.weekday == w and t >= ts.range_a.hour) \
		and (ts.range_b.weekday == w and t < ts.range_b.hour):
			result = true
		elif midnight:
			if (t >= ts.range_a.hour or t < ts.range_b.hour) \
			and (w == ts.range_a.weekday or w == ts.range_b.weekday):
				result = true
	return result
