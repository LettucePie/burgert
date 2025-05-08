extends Node3D
class_name Burger

const OFFSET_MULTI = 2
@onready var offset_4 : PackedStringArray = [
	"Bun Bottom", "Meat", "Tomato"
]
@onready var offset_2 : PackedStringArray = [
	"Lettuce", "Ketchup", "Mustard"
]

@export var ingredient3d_scene : PackedScene
@onready var ingredients_node : Node3D = $plate/ingredients

var ingredients : Array[Ingredient3D] = []
var offset_y : float = 0


func refresh_plate():
	ingredients.clear()
	for c in ingredients_node.get_children():
		c.queue_free()
	offset_y = 0


func calculate_next_offset(ingredient_name : String):
	var amount = 1
	if offset_4.has(ingredient_name): amount = 4
	if offset_2.has(ingredient_name): amount = 2
	amount *= OFFSET_MULTI
	offset_y += amount


func add_ingredient(ingredient_name : String):
	var new_ingredient3d : Ingredient3D = ingredient3d_scene.instantiate()
	new_ingredient3d.set_ingredient(new_ingredient3d.string_to_index(ingredient_name))
	ingredients_node.add_child(new_ingredient3d)
	ingredients_node.position.y = offset_y
	ingredients.append(new_ingredient3d)
	calculate_next_offset(ingredient_name)


# Called when the node enters the scene tree for the first time.
func _ready():
	refresh_plate()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
