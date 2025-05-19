extends Control
class_name Results

signal finished_results()

@onready var order_count : Label = $Panel/VBoxContainer/entry_1/ordercount
@onready var accuracy : Label = $Panel/VBoxContainer/entry_2/accuracy
@onready var score : Label = $Panel/VBoxContainer/entry_3/score
@onready var finish_button : Button = $Panel/VBoxContainer/finish


func _ready():
	self.hide()


func display_results(accuracies : PackedFloat32Array, game_score : int):
	order_count.text = str(accuracies.size())
	var accuracy_percent : float = 0.0
	for a in accuracies:
		print("Accuracy: ", a)
		accuracy_percent += a
	accuracy_percent /= accuracies.size()
	accuracy.text = str(snapped((accuracy_percent * 100), 0.01)) + "%"
	score.text = str(game_score)
	self.show()
	finish_button.grab_focus()


func _on_finish_pressed():
	emit_signal("finished_results")
