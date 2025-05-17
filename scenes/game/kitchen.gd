extends Node2D
class_name Kitchen

@export var customers : Array[Texture2D] = []
@onready var spots : Array[Sprite2D] = [
	$customers/spot_1, $customers/spot_2, $customers/spot_3, $customers/spot_4
]


func hide_all():
	for s in spots:
		s.hide()


func assign_spot(idx : int):
	hide_all()
	spots[idx].show()
	var texture_idx : int = randi_range(0, customers.size() - 1)
	spots[idx].texture = customers[texture_idx]


func _ready():
	hide_all()
