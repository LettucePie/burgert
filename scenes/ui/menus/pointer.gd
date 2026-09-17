extends TextureRect
class_name Pointer

@export var flock : Array[Control] = []


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for f in flock:
		if f.has_focus():
			reparent(f, false)
			set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
