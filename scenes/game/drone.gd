extends AnimatedSprite2D
class_name Drone

signal stole_loot()
signal drone_finished()

enum State {DORMANT, WALKING, CARRYING, HIT, DEFEATED}
var state : State = State.DORMANT
const dormant_left_x : float = -160.0
const dormant_right_x : float = 800.0
var destination_x : float = 0.0
var walk_dir : String = "_r"
#var current_state_duration : float = 0.0

@onready var adjust : Node2D = $adjust

func _set_walk_dir() -> void:
	if position.x < destination_x:
		walk_dir = "_r"
	else:
		walk_dir = "_l"


func _pick_next_state() -> void:
	adjust.hide()
	if state == State.DORMANT:
		_pick_destination()
	elif state == State.WALKING:
		_steal_the_loot()
	elif state == State.CARRYING:
		_successfully_stole_loot()
	elif state == State.HIT:
		_declare_dormant()


func _pick_destination() -> void:
	if randf() > 0.5:
		position.x = dormant_left_x
		destination_x = dormant_right_x
	else:
		position.x = dormant_right_x
		destination_x = dormant_left_x
	state = State.WALKING
	_set_walk_dir()
	play("idle" + walk_dir)


func _steal_the_loot() -> void:
	adjust.show()
	if walk_dir == "_r":
		destination_x = dormant_left_x
		$adjust/carry_right.hide()
		$adjust/carry_left.show()
	else:
		destination_x = dormant_right_x
		$adjust/carry_left.hide()
		$adjust/carry_right.show()
	_set_walk_dir()
	state = State.CARRYING
	play("carry" + walk_dir)


func _return_to_dormancy() -> void:
	if position.x <= 320:
		destination_x = dormant_left_x
	else:
		destination_x = dormant_right_x
	state = State.DEFEATED
	_set_walk_dir()
	play("walk" + walk_dir)


func _declare_dormant() -> void:
	state = State.DORMANT
	emit_signal("drone_finished")


func _successfully_stole_loot() -> void:
	_declare_dormant()
	emit_signal("stole_loot")


func enable_drone(tf : bool):
	state = State.DORMANT
	position.x = dormant_left_x
	if tf:
		show()
	else:
		hide()


func initiate_drone() -> void:
	enable_drone(true)
	_pick_next_state()


func _physics_process(delta: float) -> void:
	if state == State.WALKING:
		var pos = position
		var targ = pos
		targ.x = destination_x
		position = pos.move_toward(targ, delta * 300)
		if is_equal_approx(pos.x, destination_x):
			_pick_next_state()
	elif state == State.CARRYING:
		var pos = position
		var targ = pos
		targ.x = destination_x
		position = pos.move_toward(targ, delta * 70)
		if is_equal_approx(pos.x, destination_x):
			_pick_next_state()
	elif state == State.DEFEATED:
		var pos = position
		var targ = pos
		targ.x = destination_x
		position = pos.move_toward(targ, delta * 100)
		if is_equal_approx(pos.x, destination_x):
			_declare_dormant()
	#elif Time.get_ticks_msec() >= current_state_duration \
	#and state == State.DORMANT\
	#and (is_equal_approx(position.x, dormant_left_x) or is_equal_approx(position.x, dormant_right_x)):
		#_pick_next_state()


func get_hit() -> void:
	state = State.HIT
	$adjust/carry_left.hide()
	$adjust/carry_right.hide()
	play("hit" + walk_dir)


func _on_animation_finished() -> void:
	if animation.contains("hit"):
		_return_to_dormancy()


func _on_frame_changed() -> void:
	if animation.contains("carry"):
		if frame >= 0 \
		and frame < 10:
			adjust.position.y = lerp(0, -16, inverse_lerp(0, 10, frame))
		else:
			adjust.position.y = lerp(-16, 0, inverse_lerp(10, 19, frame))
