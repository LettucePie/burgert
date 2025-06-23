extends Node2D
class_name Customer

signal customer_finished()


@export var customer_name : String
@export var orders : Array[PackedStringArray] = []
@export var consecutive_orders : int = 1
@export var burger_portal_sprite : Sprite2D
@export var sound_player : AudioStreamPlayer2D
@export var left_area : Marker2D
@export var right_area : Marker2D
@export var munch : Munch
@export var enter_pos : Vector2
@export var stay_pos : Vector2
@export var exit_pos : Vector2
@export var enter_speed : float = 8
@export var munch_seconds : float = 1.0
@export var exit_speed : float = 8
var tic : int = 0
var default_y : float = 0
enum CUSTOMER_STATE {Entering, Waiting, Munching, Leaving, Gone}
var status : CUSTOMER_STATE = CUSTOMER_STATE.Gone
var munch_timer : int = 0


func _ready():
	if !is_in_group("Target_Area"):
		add_to_group("Target_Area")
	default_y = $character.position.y


func set_state(new_state : CUSTOMER_STATE):
	status = new_state
	if new_state == CUSTOMER_STATE.Entering:
		self.position = enter_pos
		self.show()
		burger_portal_sprite.hide()
	if new_state == CUSTOMER_STATE.Waiting:
		self.position = stay_pos
		burger_portal_sprite.show()
		play_greeting()
	if new_state == CUSTOMER_STATE.Munching:
		burger_portal_sprite.hide()
		munch.show()
		munch.play()
		munch_timer = Time.get_ticks_msec() + (munch_seconds * 1000)
	if new_state == CUSTOMER_STATE.Leaving:
		munch.stop()
		munch.hide()
	if new_state == CUSTOMER_STATE.Gone:
		emit_signal("customer_finished")


func play_greeting():
	sound_player.play()


func _physics_process(delta):
	if status == CUSTOMER_STATE.Entering:
		self.position = self.position.move_toward(stay_pos, enter_speed)
		if self.position.distance_to(stay_pos) < 1.5:
			set_state(CUSTOMER_STATE.Waiting)
	if status == CUSTOMER_STATE.Waiting:
		tic += 1
		if tic >= 60:
			tic = 0
			if $character.position.y == default_y:
				$character.position.y += 2
			else:
				$character.position.y = default_y
	if status == CUSTOMER_STATE.Munching:
		tic += 3
		if tic >= 60:
			tic = 0
			if $character.position.y == default_y :
				$character.position.y += 4
			else:
				$character.position.y = default_y
		if Time.get_ticks_msec() >= munch_timer:
			set_state(CUSTOMER_STATE.Leaving)
	if status == CUSTOMER_STATE.Leaving:
		self.position = self.position.move_toward(exit_pos, exit_speed)
		if self.position.distance_to(exit_pos) < 1.5:
			set_state(CUSTOMER_STATE.Gone)
