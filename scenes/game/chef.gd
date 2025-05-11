extends Node2D
class_name Chef

const MOVE_SPEED = 5
@onready var burger_portal : BurgerPortal = $burger_portal
@onready var current_burger : Burger = burger_portal.burger

var stations : Array[Workstation]
var current_station : Workstation = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$burger_sprite.hide()


func set_station(ws : Workstation):
	print("Setting Current Station: ", ws.ingredient)
	current_station = ws


func assess_closest_station():
	var smallest = 640
	var target = null
	if stations.size() > 0:
		for s in stations:
			var dist = abs(self.position.x - s.global_position.x)
			if dist < smallest:
				target = s
				smallest = dist
	if target != null:
		set_station(target)


func process_movement(delta):
	var move_vec : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"): move_vec.x -= 1
	if Input.is_action_pressed("right"): move_vec.x += 1
	position.x += move_vec.x * MOVE_SPEED
	if move_vec != Vector2.ZERO:
		assess_closest_station()


func process_actions(delta):
	if Input.is_action_just_pressed("confirm"):
		if current_station != null:
			print("Grabbing Ingredient: ", current_station.ingredient)
			current_burger.add_ingredient(current_station.ingredient)


func _physics_process(delta):
	process_movement(delta)
	process_actions(delta)


func _on_area_2d_area_entered(area):
	if area.is_in_group("Workstation") and !stations.has(area):
		stations.append(area)
		assess_closest_station()


func _on_area_2d_area_exited(area):
	if stations.has(area):
		stations.erase(area)

