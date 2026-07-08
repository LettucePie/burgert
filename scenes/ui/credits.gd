extends Control
class_name Credits

signal close_credits

@export var active : bool = false


func _process(delta: float) -> void:
	if active:
		if Input.is_action_just_released("cancel") \
		or Input.is_action_just_released("confirm"):
			print("Close Credits")
			emit_signal("close_credits")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			emit_signal("close_credits")
