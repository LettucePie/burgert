extends HBoxContainer

signal update_value(new_val)

@export var slider : HSlider
@export var label : Label
@export var marker : Control
var value : int = 10
var focused : bool = false


func _ready():
	if slider == null:
		slider = get_node("HSlider")
	if label == null:
		label = get_node("value")
	update_vals(false)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if focused:
		marker.show()
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
		marker.hide()


func update_vals(is_new : bool):
	slider.value = value
	label.text = str(value)
	if is_new:
		emit_signal("update_value", value)


func _on_focus_entered():
	focused = true


func _on_focus_exited():
	focused = false


func _on_volslider_drag_ended(value_changed, handle):
	value = slider.value
	update_vals(true)
