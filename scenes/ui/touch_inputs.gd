extends Control
class_name TouchInputs

@onready var left = $HBoxContainer/LeftEdge/LeftArrow
@onready var right = $HBoxContainer/RightEdge/RightArrow
@onready var submit = $HBoxContainer/RightEdge/SendSandwhich
@onready var confirm = $HBoxContainer/RightEdge/AddIngredient
@onready var cancel = $HBoxContainer/LeftEdge/TrashSandwhich
@onready var order = $HBoxContainer/LeftEdge/ViewOrder

var zone_map = [
	{
		"code" = KEY_LEFT,
		"pos" = Vector2.ZERO,
		"size" = Vector2.ZERO
	},
	{
		"code" = KEY_RIGHT,
		"pos" = Vector2.ZERO,
		"size" = Vector2.ZERO
	},
	{
		"code" = KEY_UP,
		"pos" = Vector2.ZERO,
		"size" = Vector2.ZERO
	},
	{
		"code" = KEY_Z,
		"pos" = Vector2.ZERO,
		"size" = Vector2.ZERO
	},
	{
		"code" = KEY_X,
		"pos" = Vector2.ZERO,
		"size" = Vector2.ZERO
	},
	{
		"code" = KEY_C,
		"pos" = Vector2.ZERO,
		"size" = Vector2.ZERO
	}
]

func _ready():
	map_touch_zones()


func map_touch_zones():
	zone_map[0]["pos"] = left.global_position
	zone_map[0]["size"] = left.size
	##
	zone_map[1]["pos"] = right.global_position
	zone_map[1]["size"] = right.size
	##
	zone_map[2]["pos"] = submit.global_position
	zone_map[2]["size"] = submit.size
	##
	zone_map[3]["pos"] = confirm.global_position
	zone_map[3]["size"] = confirm.size
	##
	zone_map[4]["pos"] = cancel.global_position
	zone_map[4]["size"] = cancel.size
	##
	zone_map[5]["pos"] = order.global_position
	zone_map[5]["size"] = order.size


func pos_to_keycode(pos) -> Key:
	var result = KEY_0
	
	print("Looking Through Zones filtering by pos: ", pos)
	for zone in zone_map:
		print("Looking at Zone, ", zone)
		if pos >= zone["pos"] and pos < (zone["pos"] + zone["size"]):
			result = zone["code"]
	
	return result


func _on_resized():
	if left != null:
		map_touch_zones()


func _on_update_size_timeout():
	map_touch_zones()
	$update_size.stop()
