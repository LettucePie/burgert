extends Sprite3D
class_name Title3D

var spectrum_analyzer : SpectrumAnalyzer = null
var rot_target : float = 0.0
var sca_target : float = 0.0

func _ready():
	if get_window().get_child(0) is Play:
		spectrum_analyzer = get_window().get_child(0).spectrum_analyzer


func _physics_process(delta: float) -> void:
	if spectrum_analyzer != null:
		rot_target = clampf(spectrum_analyzer.visual_data[1] * 0.2, -0.15, 0.15)
		rot_target -= clampf(spectrum_analyzer.visual_data[3] * 0.2, -0.15, 0.15)
		rotation.y = lerpf(rotation.y, rot_target, 0.2222)
		sca_target = clampf(spectrum_analyzer.visual_data[2] * 0.15, 1.0, 2.0)
		scale.y = lerpf(scale.y, sca_target, 0.2222)



#func tweenit():
	#var target = randf_range(deg_to_rad(-10), deg_to_rad(10))
	#var time = randf_range(1, 1.5)
	#var tween = create_tween()
	#tween.tween_property(self, "rotation", Vector3(0, target, 0), time).set_trans(Tween.TRANS_SINE)
	#tween.tween_callback(tweenit)
