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
		b.scale = Vector2(scale_factor, scale_factor)
		b.position = Vector2.ZERO
		b.position.x = frame.size.x / 2
		b.position.x -= (64 * b.scale.x) / 2
		print(b.position, " | ", b.scale)


func _on_update_size_timeout():
	_on_resized()
	$update_size.stop()
