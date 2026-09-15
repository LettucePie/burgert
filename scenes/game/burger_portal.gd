extends SubViewport
class_name BurgerPortal

@onready var burger : Burger = $burger
@onready var burger_render : Burger2D = $burger_2D
@export var mode_3D : bool = true
@export var mode_customer : bool = false
@export var rotating_burger : bool = false

func _ready():
	burger.ingredients_updated.connect(render_burger_2d)
	_apply_3d_mode()
	_apply_mode_customer()


func _apply_3d_mode() -> void:
	if mode_3D:
		burger.show()
		burger_render.hide()
		burger.rotate_plate = rotating_burger
		#size = Vector2(512, 512)
		disable_3d = false
	else:
		burger.hide()
		burger_render.show()
		burger_render.scale = Vector2(3.25, 3.25)
		size_2d_override = Vector2(512, 512)
		size_2d_override_stretch = true
		burger_render.position = Vector2(512 / 2, 460)
		disable_3d = true
		#own_world_3d = false
		snap_2d_transforms_to_pixel = true


func _apply_mode_customer() -> void:
	burger_render.position = Vector2(512 / 2, 330)


func set_mode_3D(tf : bool) -> void:
	mode_3D = tf
	_apply_3d_mode()


func set_mode_customer(tf : bool) -> void:
	mode_customer = tf
	_apply_mode_customer()


func render_burger_2d():
	burger_render.build_burger(burger.ingredients)
