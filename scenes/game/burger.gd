extends Node3D
class_name Burger
signal ingredients_updated()

const OFFSET_MULTI = 0.12
@onready var offset_4 : PackedStringArray = [
	"Bun Bottom", "Meat", "Tomato", "Bun"
]
@onready var offset_2 : PackedStringArray = [
	"Lettuce"
]
@onready var offset_down : PackedStringArray = [
	"Ketchup", "Mustard"
]

@export var ingredient3d_scene : PackedScene
@onready var plate : Node3D = $plate
@onready var ingredients_node : Node3D = $plate/ingredients
@onready var main_cam : Camera3D = $CameraMain

var ingredient_meshes : Array[Ingredient3D] = []
var ingredients : PackedStringArray = []
var offset_y : float = 0
var rotate_plate : bool = false


func refresh_plate():
	ingredients.clear()
	ingredient_meshes.clear()
	for c in ingredients_node.get_children():
		c.queue_free()
	offset_y = 0
	main_cam.show()
	main_cam.make_current()
	emit_signal("ingredients_updated")


func calculate_next_offset(ingredient_name : String):
	var amount = 1
	if offset_4.has(ingredient_name): amount = 4
	if offset_2.has(ingredient_name): amount = 2
	amount *= OFFSET_MULTI
	offset_y += amount


func add_ingredient(ingredient_name : String):
	var new_ingredient3d : Ingredient3D = ingredient3d_scene.instantiate()
	ingredients_node.add_child(new_ingredient3d)
	new_ingredient3d.position.y = offset_y
	new_ingredient3d.set_ingredient(new_ingredient3d.string_to_index(ingredient_name))
	ingredient_meshes.append(new_ingredient3d)
	ingredients.append(ingredient_name)
	calculate_next_offset(ingredient_name)
	emit_signal("ingredients_updated")


func assemble_burger_build(build : PackedStringArray):
	refresh_plate()
	for b in build:
		add_ingredient(b)


func _ready():
	refresh_plate()


func _physics_process(delta):
	if rotate_plate:
		plate.rotate_y(PI * delta)
