extends HBoxContainer
class_name SliderInputIconOnly
## we should be using inheritence here with SliderInput :P

signal update_value(new_val)

@onready var slider : HSlider = $HSlider
var value : int = 10
@export var normal_tex : Texture
@export var highlight_tex : Texture
var tex_set : bool = false
var focused : bool = false


func _ready():
	if slider == null:
		slider = get_node("HSlider")
	update_vals(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if focused:
		var previous = value
		if Input.is_action_just_pressed("left"):
			print("Slider Left")
			value -= 1
		elif Input.is_action_just_pressed("right"):
			print("Slider Right")
			value += 1
		if value != previous:
			if value < 0: value = 0
			if value > 10: value = 10
			update_vals(true)
		if !tex_set:
			slider.add_theme_icon_override("grabber", highlight_tex)
			tex_set = true
	else:
		if tex_set:
			slider.remove_theme_icon_override("grabber")
			tex_set = false


func update_vals(is_new : bool):
	slider.value = value
	if is_new:
		emit_signal("update_value", value)


func _on_focus_entered():
	focused = true


func _on_focus_exited():
	focused = false


func _on_volslider_drag_ended(value_changed, handle):
	value = slider.value
	update_vals(true)
