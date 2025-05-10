extends SubViewport
class_name BurgerPortal

@onready var burger : Burger = $burger
@export var rotating_burger : bool = false

func _ready():
		burger.rotate_plate = rotating_burger
