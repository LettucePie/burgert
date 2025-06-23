extends Node2D
class_name Chef

signal start_burger_submission()
signal cancel_burger_submission()
signal submit_burger()

const MOVE_SPEED = 10
@onready var burger_portal : BurgerPortal = $burger_portal
@onready var current_burger : Burger = burger_portal.burger
#@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
#@onready var frames : SpriteFrames = anim.sprite_frames
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_play : AnimationPlayer = $AnimationPlayer
@onready var state_machine = anim_tree["parameters/playback"]
@onready var grab_area : CollisionShape2D = $Area2D/CollisionShape2D
@onready var grab_left : Vector2 = $left_pos.position
@onready var grab_right : Vector2 = $right_pos.position

var active : bool = true
var stations : Array[Workstation]
var current_station : Workstation = null
var direction : String = "L"
var order_size : int = 0
var submitting_burger : bool = false
var trashing : bool = false
var trashing_ticks : int = 60
var waiting : bool = true


# Called when the node enters the scene tree for the first time.
func _ready():
	$burger_sprite.texture.viewport_path = "burger_portal"
	anim_tree.set("parameters/conditions/idle_R", true)


func reset_chef():
	current_burger.refresh_plate()
	self.position.x = 24
	_update_direction("R")
	anim_tree.set("parameters/conditions/idle_R", true)
	submitting_burger = false
	active = true
	waiting = true


func set_station(ws : Workstation):
	current_station = ws
	ws.set_highlight(true)


func assess_closest_station():
	var smallest = 640
	var target : Workstation = null
	if stations.size() > 0:
		for s in stations:
			s.set_highlight(false)
			var dist = abs(self.position.x - s.global_position.x)
			if dist < smallest:
				target = s
				smallest = dist
	if target != null:
		set_station(target)


func _update_direction(dir : String):
	if direction != dir:
		direction = dir
		if dir == "L":
			grab_area.position = grab_left
		else:
			grab_area.position = grab_right


func process_movement(delta):
	var move_vec : Vector2 = Vector2.ZERO
	if Input.is_action_pressed("left"):
		move_vec.x -= 1
		state_machine.travel("Run_L")
		_update_direction("L")
	elif Input.is_action_pressed("right"):
		move_vec.x += 1
		state_machine.travel("Run_R")
		_update_direction("R")
	if !state_machine.get_current_node().contains("Swing"):
		position.x += move_vec.x * MOVE_SPEED
		position.x = clamp(position.x, 0, 640)
	if move_vec != Vector2.ZERO:
		assess_closest_station()
		anim_tree.set("parameters/conditions/idle_L", false)
		anim_tree.set("parameters/conditions/idle_R", false)
	else:
		anim_tree.set("parameters/conditions/idle_" + direction, true)


func process_actions(delta):
	if Input.is_action_just_pressed("confirm"):
		if current_station != null \
		and current_burger.ingredients.size() < order_size:
			if current_station.ingredient == "Bun" \
			and current_burger.ingredients.size() == order_size - 1:
				print("Grabbing Top Bun")
				current_burger.add_ingredient("Bun Top")
			else:
				print("Grabbing Ingredient: ", current_station.ingredient)
				current_burger.add_ingredient(current_station.ingredient)
	if Input.is_action_just_pressed("up"):
		if current_burger.ingredients.size() >= order_size \
		and !submitting_burger:
			submitting_burger = true
			print("Enter Throw Stance")
			emit_signal("start_burger_submission")
	if Input.is_action_pressed("cancel") \
	and current_burger.ingredients.size() > 0:
		if !trashing:
			trashing = true
			trashing_ticks = 60
		trashing_ticks -= 2
		print(trashing_ticks)
		if trashing_ticks <= 0:
			trashing = false
			print("Trashing Burger")
			current_burger.refresh_plate()
	if Input.is_action_just_released("cancel") and trashing:
		trashing = false


func process_submission(delta):
	if Input.is_action_just_pressed("up") \
	or Input.is_action_just_pressed("confirm"):
		print("Send Burger")
		emit_signal("submit_burger")
	if Input.is_action_just_pressed("down") \
	or Input.is_action_just_pressed("cancel"):
		submitting_burger = false
		print("Cancel Throw")
		emit_signal("cancel_burger_submission")


func _physics_process(delta):
	if active:
		if !submitting_burger:
			process_movement(delta)
			if !waiting:
				process_actions(delta)
		else:
			process_submission(delta)


func _on_area_2d_area_entered(area):
	if area.is_in_group("Workstation") and !stations.has(area):
		stations.append(area)
		assess_closest_station()


func _on_area_2d_area_exited(area):
	if stations.has(area) and area is Workstation:
		area.set_highlight(false)
		stations.erase(area)

