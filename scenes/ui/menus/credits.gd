extends Control
class_name Credits

signal close_credits

@onready var sfx : AudioStreamPlayer = $sfx
@export var sfx_open : AudioStreamWAV
@export var sfx_close : AudioStreamWAV
@export var active : bool = false


func _process(delta: float) -> void:
	if active:
		if Input.is_action_just_released("cancel") \
		or Input.is_action_just_released("confirm"):
			emit_signal("close_credits")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			emit_signal("close_credits")


func play_sfx(open : bool) -> void:
	if open:
		sfx.stream = sfx_open
	else:
		sfx.stream = sfx_close
	sfx.play()
