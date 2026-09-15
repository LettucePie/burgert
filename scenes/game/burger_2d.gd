extends Node2D
class_name Burger2D

signal reached_target(target)

@onready var plate : Sprite2D = $plate
@onready var throw_sfx : AudioStreamPlayer2D = $AudioStreamPlayer2D
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
var start_pos : Vector2 = Vector2.ZERO
var arch_pos : Vector2 = Vector2.ZERO
var target_pos : Vector2 = Vector2.ZERO
var speed : float = 0.05
var journey : float = 0.0


func build_burger(ingredients : PackedStringArray) -> void:
	for child in plate.get_children():
		child.queue_free()
	var total_offset : int = 0
	for ingredient in ingredients:
		var new_sprite : Sprite2D = Sprite2D.new()
		var ingredient_idx : int = ingredient_table.find(ingredient)
		new_sprite.texture = ingredient_textures[ingredient_idx]
		total_offset += ingredient_offsets[ingredient_idx]
		plate.add_child(new_sprite)
		new_sprite.position = Vector2(0, total_offset * -1)
		new_sprite.flip_h = bool(randi_range(0, 1))
	#plate.position = Vector2(0, total_offset)


func set_target(target : Vector2, speed_mult : float) -> void:
	start_pos = self.position
	target_pos = target
	arch_pos = start_pos.lerp(target_pos, 0.5)
	#print("DISTANCE: ", start_pos.distance_squared_to(arch_pos))
	speed = lerpf(0.05, 0.09, inverse_lerp(90000, 8400, start_pos.distance_squared_to(arch_pos)))
	var offset : float = lerpf(0.0, 124, 
	inverse_lerp(0, 640, absf(start_pos.x - target_pos.x)))
	arch_pos.y -= offset
	speed = speed + (0.08 * (speed_mult - 0.99))
	print("THROW BURGER SPEED: ", speed, " speed mult: ", speed_mult)
	throw_sfx.play()


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var result : Vector2 = Vector2.ZERO
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	result = q0.lerp(q1, t)
	return result


func _physics_process(delta: float) -> void:
	if target_pos != Vector2.ZERO:
		journey += speed
		var pos : Vector2 = position
		pos = _quadratic_bezier(start_pos, arch_pos, target_pos, journey)
		#pos = pos.move_toward(target_pos, speed)
		#pos = pos.lerp(target_pos, 0.12 * speed)
		position = pos
		#if pos.distance_squared_to(target_pos) < 0.25:
		if journey >= 1.0:
			print("Burger Throw reached Target")
			emit_signal("reached_target", target_pos)
			queue_free()
