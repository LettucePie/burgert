extends Node2D
class_name Customer

signal customer_arrived()
signal customer_served()
signal customer_finished()


@export var customer_name : String = "Basic"
@export var orders : Array[PackedStringArray] = []
@export var consecutive_orders : int = 1
@onready var anim : AnimationPlayer = $AnimationPlayer
@export var burger_portal_sprite : Sprite2D
@onready var sound_player : AudioStreamPlayer2D = $character/AudioStreamPlayer2D
@onready var left_area : Marker2D = $character/Left
@onready var right_area : Marker2D = $character/Right
@onready var munch : Munch = $character/munch

enum CUSTOMER_STATE {Entering, Queue, Ordering, Waiting, Munching, Leaving, Gone}
var status : CUSTOMER_STATE = CUSTOMER_STATE.Gone
var tic : int = 0
var default_y : float = 0
var current_customer : bool = false


func _ready():
	if has_node("work_preview"):
		$work_preview.queue_free()
	if !is_in_group("Target_Area"):
		add_to_group("Target_Area")
	default_y = $character.position.y


func set_state(new_state : CUSTOMER_STATE):
	print("Customer: set_state: ", new_state)
	if new_state == CUSTOMER_STATE.Entering \
	and status == CUSTOMER_STATE.Gone:
		status = new_state
		#self.show()
		burger_portal_sprite.hide()
		anim.play("enter")
	elif new_state == CUSTOMER_STATE.Queue \
	and status == CUSTOMER_STATE.Entering:
		status = new_state
		anim.play("queue")
	elif new_state == CUSTOMER_STATE.Ordering \
	and status == CUSTOMER_STATE.Queue or status == CUSTOMER_STATE.Entering:
		status = new_state
		anim.play("ordering")
	elif new_state == CUSTOMER_STATE.Waiting \
	and status == CUSTOMER_STATE.Ordering:
		status = new_state
		emit_signal("customer_arrived")
	elif new_state == CUSTOMER_STATE.Munching:
		burger_portal_sprite.hide()
	elif new_state == CUSTOMER_STATE.Leaving:
		pass
	elif new_state == CUSTOMER_STATE.Gone \
	and status == CUSTOMER_STATE.Leaving:
		status = new_state
		emit_signal("customer_finished")


func play_greeting():
	sound_player.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	print(customer_name, ": finished anim: ", anim_name)
	if anim_name == "enter":
		if current_customer:
			set_state(CUSTOMER_STATE.Ordering)
		else:
			set_state(CUSTOMER_STATE.Queue)
	if anim_name == "ordering":
		set_state(CUSTOMER_STATE.Waiting)


func _process(delta: float) -> void:
	z_index = current_customer
