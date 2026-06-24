extends TextureRect
class_name TimeSlot_Result

var images : Array[Texture] = [
	preload("res://assets/images/graphics/menu/customerdex/timeslot_result_unmapped.tres"),
	preload("res://assets/images/graphics/menu/customerdex/timeslot_result_wrong.tres"),
	preload("res://assets/images/graphics/menu/customerdex/timeslot_result_possible.tres"),
	preload("res://assets/images/graphics/menu/customerdex/timeslot_result_found.tres")
]

func set_result(idx : int):
	texture = images[idx]
