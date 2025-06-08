extends ViewportTexture
class_name ViewportTextureSmart

@export var viewport_path_again : NodePath

func _init():
	if !viewport_path_again.is_empty():
		viewport_path = viewport_path_again
