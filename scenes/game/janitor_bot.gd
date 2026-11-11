extends AnimatedSprite2D
class_name JanitorBot

enum State {DORMANT, WALKING, CLEANING, HIT}
var state : State = State.DORMANT
const dormant_left_x : float = -120.0
const dormant_right_x : float = 720.0
var destination_x : float = 0.0
var current_state_duration : float = 0.0


func _set_walk_dir() -> void:
	if position.x < destination_x:
		flip_h = true
	else:
		flip_h = false



func _pick_next_state() -> void:
	if state == State.DORMANT:
		_pick_new_destination()
	elif state == State.WALKING:
		_start_cleaning()
	elif state == State.CLEANING:
		_decide_finished()
	elif state == State.HIT:
		_return_to_dormancy()


func _pick_new_destination() -> void:
	destination_x = randf_range(140, 580)
	state = State.WALKING
	_set_walk_dir()
	play("walk")


func _start_cleaning() -> void:
	current_state_duration = Time.get_ticks_msec() + randf_range(1200, 3200)
	state = State.CLEANING
	play("clean")


func _return_to_dormancy() -> void:
	if position.x <= 320:
		destination_x = dormant_left_x
	else:
		destination_x = dormant_right_x
	state = State.WALKING
	_set_walk_dir()
	play("walk")


func _declare_dormant() -> void:
	state = State.DORMANT
	current_state_duration = Time.get_ticks_msec() + randf_range(15000, 30000)
	play("clean")


func _decide_finished() -> void:
	if randf() > 0.7:
		_pick_new_destination()
	else:
		_return_to_dormancy()


func enable_bot(tf : bool):
	position.x = dormant_left_x
	state = State.DORMANT
	if tf:
		show()
		_declare_dormant()
	else:
		hide()


func _physics_process(delta: float) -> void:
	if state == State.WALKING:
		var pos = position
		var targ = pos
		targ.x = destination_x
		position = pos.move_toward(targ, delta * 100)
		if is_equal_approx(pos.x, destination_x):
			if destination_x == dormant_left_x \
			or destination_x == dormant_right_x:
				_declare_dormant()
			else:
				_start_cleaning()
	elif Time.get_ticks_msec() >= current_state_duration:
		_pick_next_state()


func get_hit() -> void:
	state = State.HIT
	current_state_duration = Time.get_ticks_msec() + 3000
	play("hit")
