extends Node2D
class_name Submit

const SPEED = 700
@export var x_min : float = 10
@export var x_max : float = 630
@onready var target : Node2D = $crosshair
@onready var line : Line2D = $Line2D


var playing : bool = false
var travel : int = 1
var spot_areas : Array[Area2D] = []
var current_area : Area2D = null
var current_area_idx : int = -1
var start_pos_x : float = 0


func _ready():
	self.hide()


func _physics_process(delta):
	if playing:
		var new_pos = target.position.x
		new_pos += (SPEED * delta) * travel
		new_pos = clamp(new_pos, x_min, x_max)
		target.position.x = new_pos
		if new_pos >= x_max:
			travel = -1
		elif new_pos <= x_min:
			travel = 1
		var points : PackedVector2Array = [
			Vector2(start_pos_x, 328), Vector2(new_pos, 78)
		]
		line.points = points


func set_playing(tf : bool, start_pos : float):
	playing = tf
	visible = tf
	spot_areas.clear()
	current_area = null
	if tf:
		target.position.x = start_pos
		start_pos_x = start_pos
		travel = 1
	else:
		current_area_idx = -1


func _assess_current_area():
	current_area = null
	var smallest = 640
	if spot_areas.size() > 0:
		for spot in spot_areas:
			var dist = abs(target.position.x - spot.global_position.x)
			if dist < smallest:
				current_area = spot
				smallest = dist
	if current_area != null:
		print("Current Target: ", current_area.name)
		current_area_idx = int(current_area.name.lstrip("spot_")) - 1
	else:
		current_area_idx = -1


func _on_area_target_area_entered(area):
	if area.is_in_group("Target_Area") and !spot_areas.has(area):
		spot_areas.append(area)
		_assess_current_area()


func _on_area_target_area_exited(area):
	if area.is_in_group("Target_Area") and spot_areas.has(area):
		spot_areas.erase(area)
		_assess_current_area()
