extends Node
class_name SpectrumAnalyzer

var active : bool = false
@export var audio_bus_id : int = 0
@export var audio_bus_fx : int = 1
var visualizer_instance : AudioEffectSpectrumAnalyzerInstance = null
var frequency_ranges : PackedVector2Array = [
	Vector2(0, 60),
	Vector2(60, 250),
	Vector2(250, 500),
	Vector2(500, 2000),
	Vector2(2000, 20000)
]
var balancer_weights : PackedFloat32Array = [
	0.95,
	1.00,
	2.35,
	3.80,
	5.60
]
var spectrum_data : PackedVector2Array = []
var total_magnitude_raw : float = 0.0
var total_magnitude_scaled : float = 0.0
var visual_data : PackedFloat32Array = [0.0, 0.0, 0.0, 0.0, 0.0]
var largest_value : float = 0.0


func set_active(tf : bool) -> void:
	AudioServer.set_bus_effect_enabled(audio_bus_id, audio_bus_fx, tf)
	active = tf


func _ready():
	visualizer_instance = AudioServer.get_bus_effect_instance(audio_bus_id, audio_bus_fx)


func _analyze_spectrum() -> void:
	spectrum_data.clear()
	total_magnitude_raw = 0.0
	total_magnitude_scaled = 0.0
	for idx in frequency_ranges.size():
		var range : Vector2 = frequency_ranges[idx]
		var scaler : float = balancer_weights[idx]
		var magnitude = visualizer_instance.get_magnitude_for_frequency_range(range.x, range.y)
		total_magnitude_raw += magnitude.length()
		magnitude *= scaler
		total_magnitude_scaled += magnitude.length()
		spectrum_data.append(magnitude)


func _calculate_visualizer_data() -> void:
	for idx in spectrum_data.size():
		var raw_value = spectrum_data[idx].length_squared() * 10000
		var lerp_speed : float = 0.90
		if raw_value < visual_data[idx]:
			lerp_speed = 0.35
		visual_data[idx] = lerpf(visual_data[idx], raw_value, lerp_speed)


func _physics_process(delta: float) -> void:
	if active:
		if visualizer_instance != null:
			_analyze_spectrum()
		_calculate_visualizer_data()
