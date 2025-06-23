extends Node2D
class_name Customer


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
var active : bool = false
var tic : int = 0
var default_y : float = 0
var munching : bool = false


func _ready():
	if !is_in_group("Target_Area"):
		add_to_group("Target_Area")
	default_y = $character.position.y


func set_active(tf : bool):
	active = tf
	if tf:
		play_greeting()


func play_greeting():
	sound_player.play()


func _physics_process(delta):
	if active:
		tic += 1
		if tic >= 60:
			tic = 0
			if $character.position.y == default_y:
				$character.position.y += 2
			else:
				$character.position.y = default_y
