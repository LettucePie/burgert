extends Sprite2D
class_name Money_FX

var anim_finished : bool = false
var sound_finished : bool = false


func play_anim(anim_name : String) -> void:
	anim_finished = false
	sound_finished = false
	$AnimationPlayer.play(anim_name)


func play_bop(good_bad : bool) -> void:
	var pitch : float = 1.0
	if good_bad:
		pitch = randf_range(1.0, 1.2)
	else:
		pitch = randf_range(0.5, 0.7)
	get_node("bop").pitch_scale = pitch
	get_node("bop").play()


func _death_check() -> void:
	if anim_finished and sound_finished:
		self.queue_free()


func _on_bop_finished() -> void:
	_death_check()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_death_check()


func flick_away() -> void:
	var target : Vector2 = self.position
	var rot : float = self.rotation + (PI / 2)
	if randi_range(0, 1) > 0:
		target += Vector2(-20, -20)
		rot = self.rotation - (PI / 2)
	else:
		target += Vector2(20, -20)
	var tween : Tween = create_tween()
	tween.tween_property(self, "position", target, 0.2)
	tween.set_parallel()
	tween.tween_property(self, "rotation", rot, 0.2)
