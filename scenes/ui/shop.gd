extends Control
class_name Shop

signal close_shop()

@onready var main : Control = $phone/main
@onready var finished : Button = $phone/main/vcont1/finished


func _ready():
	open_shop()


func open_shop():
	main.show()
	finished.grab_focus()


func _on_finished_pressed() -> void:
	emit_signal("close_shop")
