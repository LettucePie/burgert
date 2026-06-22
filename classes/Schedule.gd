extends Resource
class_name Schedule

@export var time_slots : Array[TimeSlot] = []

func within_range(w : Time.Weekday, t : int, ts : TimeSlot) -> bool:
	var result : bool = false
	var midnight : bool = ts.range_a.weekday != ts.range_b.weekday
	if (ts.range_a.weekday == w and t >= ts.range_a.hour) \
	and (ts.range_b.weekday == w and t < ts.range_b.hour):
		result = true
	elif midnight:
		if (t >= ts.range_a.hour or t < ts.range_b.hour) \
		and (w == ts.range_a.weekday or w == ts.range_b.weekday):
			result = true
	return result
