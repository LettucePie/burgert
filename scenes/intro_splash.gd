extends AnimatedSprite2D
class_name IntroSplash

signal intro_splash_fading


func _ready() -> void:
	self.show()
	play("default")


func _on_frame_changed() -> void:
	if frame == 44:
		var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), 2.0)
		emit_signal("intro_splash_fading")


func _on_animation_finished() -> void:
	hide()
