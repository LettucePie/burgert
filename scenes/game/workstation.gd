extends Area2D
class_name Workstation


@export var ingredient : String = "Lettuce"
@export var highlight : Sprite2D = null
@onready var ingredient_sprite : AnimatedSprite2D = $ingredient_sprite
@onready var sfx : AudioStreamPlayer = $AudioStreamPlayer
var runic : bool = false
@export var rune : Rune
@export var magic_pop : AnimatedSprite2D
var magic_pop_rot_offset : float = 0.0


func _ready():
	set_highlight(false)
	if magic_pop != null:
		magic_pop.frame_changed.connect(_pop_frame_update)
		magic_pop.animation_finished.connect(_pop_finish)
		magic_pop.hide()


func _physics_process(delta):
	if magic_pop.visible:
		magic_pop.rotate(magic_pop_rot_offset)


func set_highlight(tf : bool):
	if runic:
		rune.highlighted = tf
	else:
		highlight.visible = tf
		if tf:
			ingredient_sprite.play()
		else:
			ingredient_sprite.stop()
			ingredient_sprite.frame = 0


func set_runic(tf : bool):
	runic = tf
	magic_pop.show()
	randomize()
	magic_pop.rotation = randf_range(0, TAU)
	magic_pop.play("pop", randf_range(0.8, 1.4))
	magic_pop_rot_offset = randf_range(PI * -0.002, PI * 0.002)


func _pop_frame_update():
	if magic_pop.frame == 4:
		if runic:
			ingredient_sprite.hide()
			rune.show()
		else:
			ingredient_sprite.show()
			rune.hide()


func _pop_finish():
	magic_pop.hide()


func force_hide_magic_pop():
	magic_pop.hide()


func pickup_sfx() -> void:
	sfx.play()
