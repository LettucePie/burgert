extends Sprite2D
class_name BlurCustomer

@export var sprites : Array[AtlasTexture] = []
var destinations : PackedVector2Array = [
	Vector2(-60, 250),
	Vector2(700, 250)
]
var destination : int = 0
var active : bool = false
var dormancy_timer : int = 0
var speed : float = 8.0
var hiding : bool = false


func reset_pos() -> void:
	hiding = false
	destination = 0
	position = destinations[0]
	initial_dormancy()


func _dormant_time() -> void:
	dormancy_timer = Time.get_ticks_msec() + randi_range(500, 15000)
	active = false


func initial_dormancy() -> void:
	dormancy_timer = Time.get_ticks_msec() + randi_range(10000, 14000)
	active = false


func _ready() -> void:
	initial_dormancy()


func _physics_process(delta: float) -> void:
	if active:
		position = position.move_toward(destinations[destination], speed)
		if is_equal_approx(position.x, destinations[destination].x) \
		and !hiding:
			_dormant_time()
	else:
		if Time.get_ticks_msec() > dormancy_timer:
			active = true
			speed = randf_range(5.0, 10.0)
			if randf() > 0.5:
				destination = 0
				position = destinations[1]
			else:
				destination = 1
				position = destinations[0]
			texture = sprites.pick_random()
			flip_h = randf() > 0.5


func flee() -> void:
	if active:
		speed = 10.0
		destination = 0
		if position.x > 320:
			destination = 1
	hiding = true
