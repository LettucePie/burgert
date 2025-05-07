extends Node2D
class_name Chef

var stations : Array[Workstation]
var current_station : Workstation = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func set_station(ws : Workstation):
	print("Setting Current Station: ", ws.ingredient)


func assess_closest_station():
	var smallest = 640
	var target = null
	if stations.size() > 0:
		for s in stations:
			var dist = abs(self.position.x - s.position.x)
			if dist < smallest:
				target = s
				smallest = dist
	if target != null:
		set_station(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var move_vec : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"): move_vec.x -= 1
	if Input.is_action_pressed("right"): move_vec.x += 1
	position.x += move_vec.x * delta
	if move_vec != Vector2.ZERO:
		assess_closest_station()


func _on_area_2d_area_entered(area):
	if area.is_in_group("Workstation") and !stations.has(area):
		stations.append(area)
		assess_closest_station()


func _on_area_2d_area_exited(area):
	if stations.has(area):
		stations.erase(area)

