extends Area2D
class_name Customer


@export var customer_name : String
@export var orders : Array[PackedStringArray] = []
@export var consecutive_orders : int = 1



func _ready():
	if !is_in_group("Target_Area"):
		add_to_group("Target_Area")
