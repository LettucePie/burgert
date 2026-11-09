extends Sprite2D
class_name RandomDeskDeco

@export var textures : Array[Texture2D] = []


func assign_random_texture() -> void:
	randomize()
	texture = textures.pick_random()
	rotation_degrees = randf_range(-52.0, -50.0)


func _ready() -> void:
	assign_random_texture()
