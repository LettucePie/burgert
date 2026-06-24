extends HBoxContainer
class_name SliderInput

signal update_value(new_val)

#@export var slider : HSlider
#@export var label_label : Label
#@export var value_label : Label
@onready var slider : HSlider = $HSlider
@onready var label_label : Label = $Label
@onready var value_label : Label = $value
var label_color_default : Color = "00000071"
var label_color_highlight : Color = "cfcfcfe3"
var value : int = 10
var focused : bool = false


func _ready():
	if slider == null:
		slider = get_node("HSlider")
	if value_label == null:
		value_label = get_node("value")
	if label_label == null:
		label_label = get_node("Label")
	update_vals(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if focused:
		label_label.add_theme_color_override("font_color", label_color_highlight)
		value_label.add_theme_color_override("font_color", label_color_highlight)
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
	else:
		label_label.remove_theme_color_override("font_color")
		value_label.remove_theme_color_override("font_color")


func update_vals(is_new : bool):
	slider.value = value
	value_label.text = str(value)
	if is_new:
		emit_signal("update_value", value)


func _on_focus_entered():
	focused = true


func _on_focus_exited():
	focused = false


func _on_volslider_drag_ended(value_changed, handle):
	value = slider.value
	update_vals(true)
