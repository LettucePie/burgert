extends Node2D
class_name Chef

@warning_ignore("unused_signal")
signal start_burger_submission()
@warning_ignore("unused_signal")
signal cancel_burger_submission()
@warning_ignore("unused_signal")
signal submit_burger()
@warning_ignore("unused_signal")
signal chef_ready()
@warning_ignore("unused_signal")
signal trashing_start()
@warning_ignore("unused_signal")
signal trashing_progress(val)
@warning_ignore("unused_signal")
signal trashing_stopped()
@warning_ignore("unused_signal")
signal grabbed_results_door(obj)
@warning_ignore("unused_signal")
signal closed_results_door()
#signal chef_idle(tf)

const MOVE_SPEED = 10
@onready var burger_portal : BurgerPortal = $burger_portal
@onready var current_burger : Burger = burger_portal.burger
@onready var burger_sprite : Sprite2D = $burger_sprite
#@onready var anim : AnimatedSprite2D = $AnimatedSprite2D
#@onready var frames : SpriteFrames = anim.sprite_frames
@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_play : AnimationPlayer = $AnimationPlayer
@onready var state_machine = anim_tree["parameters/playback"]
@onready var grab_area : CollisionShape2D = $Area2D/CollisionShape2D
@onready var grab_left : Vector2 = $left_pos.position
@onready var grab_right : Vector2 = $right_pos.position
@onready var sfx : AudioStreamPlayer2D = $sfx
@export var trash_sfx : AudioStreamWAV = null
@export var charge_up_sfx : AudioStreamWAV = null

var active : bool = true
var idle_counter : int = 0
var stations : Array[Workstation]
var current_station : Workstation = null
var direction : String = "L"
var turn_rest : int = 0
var order_size : int = 0
var submitting_burger : bool = false
var burger_thrown : bool = false
var trashing : bool = false
var trashing_ticks : int = 60
var waiting : bool = true
var charging_rate : float = 1.0
var charging_rate_min : float = 1.0
var charging_rate_max : float = 2.0
var charging_speed : float = 5.0
@onready var quick_throw_threshold : float = ((charging_rate_max - charging_rate_min) / 2) + charging_rate_min
var post_game : bool = false
var current_dance : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	burger_sprite.texture.viewport_path = "burger_portal"
	anim_tree.set("parameters/conditions/idle_R", true)
	#burger_portal.set_mode_3D(false)


func reset_chef():
	set_post_game(false)
	anim_tree.active = true
	current_burger.refresh_plate()
	self.position.x = -100
	_update_direction("R")
	anim_tree.set("parameters/conditions/post_game", false)
	anim_tree.set("parameters/conditions/idle_R", true)
	submitting_burger = false
	burger_thrown = false
	set_active(false)
	sfx.stop()
	waiting = true
	burger_sprite.show()
	idle_counter = 0


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


@warning_ignore("unused_parameter")
func process_movement(delta):
	var move_vec : Vector2 = Vector2.ZERO
	#burger_sprite.offset = Vector2.ZERO
	if Input.is_action_pressed("left"):
		move_vec.x -= 1
		if turn_rest >= 12:
			state_machine.start("Run_L")
		else:
			if direction == "R":
				state_machine.travel("Swing_L")
			else:
				state_machine.travel("Run_L")
		_update_direction("L")
		#if !burger_portal.mode_3D:
			#burger_sprite.offset = Vector2(0, -10.0)
	elif Input.is_action_pressed("right"):
		move_vec.x += 1
		if turn_rest >= 12:
			state_machine.start("Run_R")
		else:
			if direction == "L":
				state_machine.travel("Swing_R")
			else:
				state_machine.travel("Run_R")
		_update_direction("R")
	#if !state_machine.get_current_node().contains("Swing"):
	position.x += move_vec.x * MOVE_SPEED
	position.x = clamp(position.x, 0, 640)
	if move_vec != Vector2.ZERO:
		assess_closest_station()
		anim_tree.set("parameters/conditions/idle_L", false)
		anim_tree.set("parameters/conditions/idle_R", false)
		idle_counter = 0
		turn_rest = 0
	else:
		anim_tree.set("parameters/conditions/idle_" + direction, true)
		turn_rest = clamp(turn_rest + 1, 0, 60)


@warning_ignore("unused_parameter")
func process_actions(delta):
	if Input.is_action_just_pressed("confirm"):
		if current_station != null \
		and current_burger.ingredients.size() < order_size:
			if current_station.ingredient == "Bun" \
			and current_burger.ingredients.size() == order_size - 1:
				current_burger.add_ingredient("Bun Top")
			else:
				current_burger.add_ingredient(current_station.ingredient)
			current_station.pickup_sfx()
			idle_counter = 0
	if Input.is_action_just_pressed("up"):
		if !submitting_burger:
			submitting_burger = true
			burger_thrown = false
			charging_rate = charging_rate_min
			state_machine.travel("Chargup_" + direction)
			emit_signal("start_burger_submission")
			idle_counter = 0
	if Input.is_action_pressed("cancel") \
	and current_burger.ingredients.size() > 0:
		if !trashing:
			trashing = true
			trashing_ticks = 60
			emit_signal("trashing_start")
		trashing_ticks -= 2
		emit_signal("trashing_progress", abs(float((trashing_ticks - 60) / float(60))))
		if trashing_ticks <= 0:
			trashing = false
			sfx.stream = trash_sfx
			state_machine.travel("Trash_" + direction)
			sfx.play()
			current_burger.refresh_plate()
			emit_signal("trashing_stopped")
		idle_counter = 0
	if Input.is_action_just_released("cancel") and trashing:
		trashing = false
		emit_signal("trashing_stopped")


func process_submission(delta):
	if Input.is_action_pressed("up"):
		charging_rate = clampf(
			charging_rate + charging_speed * delta, 
			charging_rate_min,
			charging_rate_max
		)
		if !sfx.playing:
			sfx.stream = charge_up_sfx
			sfx.play()
	else:
		charging_rate = clampf(
			charging_rate - charging_speed * delta,
			charging_rate_min,
			charging_rate_max
		)
	if state_machine.get_current_node().contains("Charging"):
		anim_tree.set('parameters/Charging_L/TimeScale/scale', charging_rate)
		anim_tree.set('parameters/Charging_R/TimeScale/scale', charging_rate)
	if (Input.is_action_just_pressed("up") \
	or (Input.is_action_just_released("up") and charging_rate > quick_throw_threshold) \
	or Input.is_action_just_pressed("confirm")) \
	and !burger_thrown:
		emit_signal("submit_burger")
		burger_thrown = true
		state_machine.travel("Throw_" + direction)
		charging_rate = charging_rate_min
		idle_counter = 0
		if sfx.stream == charge_up_sfx:
			sfx.stop()
	if Input.is_action_just_pressed("down") \
	or Input.is_action_just_pressed("cancel"):
		submitting_burger = false
		burger_thrown = false
		emit_signal("cancel_burger_submission")
		state_machine.travel("Idle_" + direction)
		if sfx.stream == charge_up_sfx:
			sfx.stop()


func _physics_process(delta):
	if active:
		idle_counter += 1
		if !submitting_burger:
			process_movement(delta)
			if !waiting:
				process_actions(delta)
		else:
			process_submission(delta)
		if idle_counter >= 1200:
			state_machine.travel("Idle_Sting_" + direction)
			idle_counter = 35


func _on_area_2d_area_entered(area):
	if area.is_in_group("Workstation") and !stations.has(area):
		stations.append(area)
		assess_closest_station()


func _on_area_2d_area_exited(area):
	if stations.has(area) and area is Workstation:
		area.set_highlight(false)
		stations.erase(area)


func intro_animation_override():
	anim_tree.active = false
	anim_play.play("Intro")


func intro_animation_finished():
	anim_tree.active = true
	emit_signal("chef_ready")
	set_active(true)


func set_active(tf : bool):
	active = tf
	if !tf:
		trashing = false
		emit_signal("trashing_stopped")


func set_post_game(tf : bool) -> void:
	post_game = tf
	if tf:
		process_mode = PROCESS_MODE_WHEN_PAUSED
		z_index = 3
		anim_tree.set("parameters/conditions/post_game", true)
		state_machine.travel("Jump_" + direction)
	else:
		process_mode = PROCESS_MODE_INHERIT
		z_index = 0


func jump_tween() -> void:
	var tween = create_tween().set_trans(Tween.TRANS_SPRING)
	tween.tween_property(self, "position", Vector2(position.x, 20.0), 0.75)
	tween.tween_callback(emit_signal.bind("grabbed_results_door", self))


func _quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var result : Vector2 = Vector2.ZERO
	var q0 = p0.lerp(p1, t)
	var q1 = p1.lerp(p2, t)
	result = q0.lerp(q1, t)
	return result


func _tween_a_geddon(tt, hm, st, p0, p1, p2, r) -> void:
	if st.time_left <= 0.01:
		position = p2
	else:
		var tween = create_tween()
		tween.tween_property(self, "position", _quadratic_bezier(p0, p1, p2, 1.0 - (st.time_left / tt)), r)
		tween.tween_callback(_tween_a_geddon.bind(tt, hm, st, p0, p1, p2, r))


func bounce_to_corner() -> void:
	var time_total : float = 0.4
	time_total = lerpf(0.1, 0.55, position.x / 640.0)
	var height_max : float = 160.0
	height_max = lerpf(200.0, 160.0, position.x / 640.0)
	var timer : SceneTreeTimer = get_tree().create_timer(time_total)
	var p0 : Vector2 = self.position
	var p2 : Vector2 = Vector2(34.0, 380)
	var p1 : Vector2 = p0.lerp(p2, 0.5)
	p1.y = height_max
	_tween_a_geddon(time_total, height_max, timer, p0, p1, p2, 0.01)


#func pick_next_dance() -> void:
	#var options : Array = [1, 2, 3, 4]
	#for o in options:
		#anim_tree.set("parameters/Dancing/conditions/dance_" + str(o), false)
	#options.erase(current_dance)
	#current_dance = options.pick_random()
	#anim_tree.set("parameters/Dancing/conditions/dance_" + str(current_dance), true)
