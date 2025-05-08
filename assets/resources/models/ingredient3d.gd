extends Node3D
class_name Ingredient3D

enum INGREDIENT {
	BUN_BOTTOM, BUN_TOP, MEAT, 
	TOMATO, LETTUCE, CHEESE, 
	KETCHUP, MUSTARD
}
@onready var meshes : Array[MeshInstance3D] = [
	$Bun_Bottom, $Bun_Top, $Meat,
	$Tomato, $Lettuce, $Cheese,
	$Ketchup, $Mustard
]
@onready var string_conversion : PackedStringArray = [
	"Bun Bottom", "Bun Top", "Meat",
	"Tomato", "Lettuce", "Cheese",
	"Ketchup", "Mustard"
]
@export var current_ingredient : INGREDIENT = INGREDIENT.BUN_BOTTOM


func hide_all():
	for m in meshes:
		m.visible = false


func set_ingredient(arg1 : INGREDIENT):
	current_ingredient = arg1
	hide_all()
	meshes[arg1].visible = true
	rotate_y(randf_range(0.0, PI))


func _ready():
	set_ingredient(current_ingredient)


func string_to_index(s : String):
	var result : int = 0
	if string_conversion.has(s):
		result = string_conversion.find(s)
	return result
