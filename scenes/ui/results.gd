extends Control
class_name Results

signal finished_results()

@onready var order_count : Label = $Panel/VBoxContainer/ordercount
@onready var accuracy : Label = $Panel/VBoxContainer/entry_2/accuracy
@onready var score : Label = $Panel/VBoxContainer/entry_3/score
@onready var finish_button : Button = $Panel/VBoxContainer/finish

var stat_order_count : int = 0


@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_play : AnimationPlayer = $AnimationPlayer
var animating : bool = false
var animation_step : int = 0



func _ready():
	self.hide()


func display_results(accuracies : PackedFloat32Array, game_score : int):
	#order_count.text = str(accuracies.size())
	stat_order_count = accuracies.size()
	var accuracy_percent : float = 0.0
	for a in accuracies:
		print("Accuracy: ", a)
		accuracy_percent += a
	accuracy_percent /= accuracies.size()
	accuracy.text = str(snapped((accuracy_percent * 100), 0.01)) + "%"
	score.text = str(game_score)
	self.show()
	animating = true
	animation_step = 0
	finish_button.grab_focus()


func _on_finish_pressed():
	if !animating:
		emit_signal("finished_results")
