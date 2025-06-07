extends Area2D
class_name Customer


@export var customer_name : String
@export var orders : Array[PackedStringArray] = []
@export var consecutive_orders : int = 1
@export var burger_portal_sprite : Sprite2D
@export var sound_player : AudioStreamPlayer2D


func _ready():
	if !is_in_group("Target_Area"):
		add_to_group("Target_Area")
