extends Resource
class_name Schedule

class DateTimeMark:
	var weekday : Time.Weekday = Time.Weekday.WEEKDAY_SUNDAY
	var hour : int = 0

class TimeSlot:
	var range_a : DateTimeMark
	var range_b : DateTimeMark
	
	func within_range(w : Time.Weekday, t : int) -> bool:
		var result : bool = false
		var midnight : bool = range_a.weekday != range_b.weekday
		if (range_a.weekday == w and t >= range_a.hour) \
		and (range_b.weekday == w and t < range_b.hour):
			result = true
		elif midnight:
			if (t >= range_a.hour or t < range_b.hour) \
			and (w == range_a.weekday or w == range_b.weekday):
				result = true
		return result
