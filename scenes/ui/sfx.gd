extends AudioStreamPlayer2D
class_name SFX

@export var library : Array[AudioStreamWAV] = []


func _ready() -> void:
	finished.connect(_on_finished)


func play_target_audio_WAV(audio : AudioStreamWAV) -> void:
	stream = audio
	play()


func play_random():
	stream = library.pick_random()
	play()


func _on_finished() -> void:
	pass
