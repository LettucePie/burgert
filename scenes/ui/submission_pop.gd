extends Control
class_name SubmissionPop

@warning_ignore("unused_signal")
signal receipt_fully_popped()
@warning_ignore("unused_signal")
signal tip_revealed()

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var order_number_label : Label = $TextureRect/VBoxContainer/orderno
@onready var accuracy_label : Label = $TextureRect/VBoxContainer/accuracy_entry/accuracy
@onready var time_label : Label = $TextureRect/VBoxContainer/time_entry/time
@onready var chargeup_label : Label = $TextureRect/VBoxContainer/charge_entry/charge
@onready var tip_label : Label = $TextureRect/VBoxContainer/bonus_entry/tip
@onready var total_label : Label = $TextureRect/VBoxContainer/total
@export var result_gradient : Gradient = null


func set_order_num(arg : int):
	order_number_label.text = str(arg)


func set_accuracy(submit : int, request : int, grad_score : float):
	accuracy_label.text = str(submit) + "/" + str(request)
	accuracy_label.self_modulate = result_gradient.sample(grad_score)


func set_time(arg : float, grad_score : float):
	time_label.text = str(snapped(arg, 0.1)) + "secs"
	time_label.self_modulate = result_gradient.sample(grad_score)


func set_chargeup(arg : float):
	chargeup_label.text = str(snapped(arg, 0.1)) + "x"
	chargeup_label.self_modulate = result_gradient.sample(arg / 2.0)


func set_tip(arg : String):
	tip_label.text = arg
	var target_color : Color = Color.BLACK
	if arg == "Basic":
		target_color = result_gradient.colors[3]
	elif arg == "Bonus":
		target_color = result_gradient.colors[2]
	elif arg == "Ultra":
		target_color = result_gradient.colors[1]
	tip_label.self_modulate = target_color


func set_total(arg : int):
	total_label.text = str(arg)


func popup():
	anim.play("spawn")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "spawn":
		emit_signal("receipt_fully_popped")
		anim.play("vanish")
