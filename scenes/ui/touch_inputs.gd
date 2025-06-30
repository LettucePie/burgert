extends Control
class_name TouchInputs

@export var buttons : Array[TouchScreenButton]


func _ready():
	_on_resized()


func _on_resized():
	for b in buttons:
		var frame = b.get_parent()
		var min_edge = frame.size.x
		if frame.size.y < min_edge:
			min_edge = frame.size.y
		var scale_factor = float(min_edge) / 64.0
		print(min_edge)
		print(scale_factor)
		b.scale = Vector2(scale_factor, scale_factor)
		b.position = Vector2.ZERO


func _on_update_size_timeout():
	_on_resized()
	$update_size.stop()
