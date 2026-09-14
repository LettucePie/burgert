extends Node2D
class_name Burger2D

signal reached_target(target)

@onready var plate : Sprite2D = $plate
@export var ingredient_textures : Array[Texture2D] = []
var ingredient_table : PackedStringArray = [
	"Bun",
	"Bun Top",
	"Meat",
	"Cheese",
	"Lettuce",
	"Tomato",
	"Ketchup",
	"Mustard"
]
var ingredient_offsets : PackedInt32Array = [
	4,
	7,
	4,
	2,
	2,
	2,
	1,
	1
]
var target_pos : Vector2 = Vector2.ZERO


func build_burger(ingredients : PackedStringArray) -> void:
	var total_offset : int = 0
	for ingredient in ingredients:
		var new_sprite : Sprite2D = Sprite2D.new()
		var ingredient_idx : int = ingredient_table.find(ingredient)
		new_sprite.texture = ingredient_textures[ingredient_idx]
		total_offset += ingredient_offsets[ingredient_idx]
		plate.add_child(new_sprite)
		new_sprite.position = Vector2(0, total_offset * -1)
		new_sprite.flip_h = bool(randi_range(0, 1))
	plate.position = Vector2(0, total_offset)


func set_target(target : Vector2) -> void:
	target_pos = target
	#look_at(target)
	#rotate(PI / 4)


func _process(delta: float) -> void:
	if target_pos != Vector2.ZERO:
		var pos : Vector2 = position
		pos = pos.lerp(target_pos, 0.12)
		position = pos
		if pos.distance_squared_to(target_pos) < 0.25:
			print("Burger Throw reached Target")
			emit_signal("reached_target", target_pos)
			queue_free()
