extends Sprite3D
class_name Title3D

@export var spectrum_analyzer : SpectrumAnalyzer = null
var rot_target : float = 0.0
var sca_target : float = 0.0

func _ready():
	spectrum_analyzer.set_active(true)


func _physics_process(_delta: float) -> void:
	if spectrum_analyzer != null:
		rot_target = clampf((spectrum_analyzer.visual_data[0] + spectrum_analyzer.visual_data[1]) * 0.25, -0.25, 0.25)
		rot_target -= clampf((spectrum_analyzer.visual_data[3] + spectrum_analyzer.visual_data[4]) * 0.25, -0.25, 0.25)
		rotation.y = lerpf(rotation.y, rot_target, 0.022)
		sca_target = clampf(spectrum_analyzer.total_magnitude_raw * 35, 0.8, 1.8)
		scale.y = lerpf(scale.y, sca_target, 0.1)



#func tweenit():
	#var target = randf_range(deg_to_rad(-10), deg_to_rad(10))
	#var time = randf_range(1, 1.5)
	#var tween = create_tween()
	#tween.tween_property(self, "rotation", Vector3(0, target, 0), time).set_trans(Tween.TRANS_SINE)
	#tween.tween_callback(tweenit)


func _on_visibility_changed() -> void:
	spectrum_analyzer.set_active(visible)
