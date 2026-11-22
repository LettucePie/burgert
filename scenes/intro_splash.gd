extends AnimatedSprite2D
class_name IntroSplash

signal intro_splash_fading


func _ready():
	hide()


func play_intro():
	self.show()
	frame = 0
	play("no_ai")
	$AudioStreamPlayer.play()


func _on_frame_changed() -> void:
	if frame == 56:
		var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0)
		emit_signal("intro_splash_fading")


func _on_animation_finished() -> void:
	print("HIDE")
	hide()
