extends Node2D
class_name Feedback

@onready var anim : AnimationPlayer = $AnimationPlayer
@export var feedback_fantastic : AudioStreamWAV = null
@export var feedback_satisfactory : AudioStreamWAV = null
@export var feedback_disappointed : AudioStreamWAV = null
@onready var feedback_sfx : AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	$happy.hide()
	$sad.hide()
	$money.hide()


func play(level : int):
	self.show()
	feedback_sfx.stream = feedback_disappointed
	if level <= 0:
		anim.play("disappointing")
	if level == 1:
		anim.play("satisfactory")
		feedback_sfx.stream = feedback_satisfactory
	if level == 2:
		anim.play("fantastic")
		feedback_sfx.stream = feedback_fantastic
	feedback_sfx.play()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	self.hide()
