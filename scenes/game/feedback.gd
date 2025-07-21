extends Node2D
class_name Feedback

@onready var anim : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	$happy.hide()
	$sad.hide()
	$money.hide()

func play(level : int):
	self.show()
	if level <= 0:
		anim.play("disappointing")
	if level == 1:
		anim.play("satisfactory")
	if level == 2:
		anim.play("fantastic")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.hide()
