extends Sprite3D


func _ready():
	randomize()
	tweenit()


func tweenit():
	var target = randf_range(deg_to_rad(-10), deg_to_rad(10))
	var time = randf_range(1, 1.5)
	var tween = create_tween()
	tween.tween_property(self, "rotation", Vector3(0, target, 0), time)
	tween.tween_callback(tweenit)
