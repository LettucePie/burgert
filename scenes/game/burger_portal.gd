extends SubViewport
class_name BurgerPortal

@onready var burger : Burger = $burger
@export var rotating_burger : bool = false

func _ready():
		burger.rotate_plate = rotating_burger


func return_burger_screenshot() -> Texture2D:
	var result : Texture2D = null
	
	burger.main_cam.hide()
	burger.screencap_cam.show()
	burger.screencap_cam.make_current()
	var vp_tex : ViewportTexture = get_texture()
	var vp_image : Image = vp_tex.get_image()
	result = ImageTexture.create_from_image(vp_image)
	burger.main_cam.show()
	burger.main_cam.make_current()
	burger.screencap_cam.hide()
	
	return result
