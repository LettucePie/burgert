extends Control
class_name Records

signal close_records()

@onready var records_page : Control = $records_page
@onready var total_score : Label = $records_page/VBoxContainer/total_score/value
@onready var highest_score : Label = $records_page/VBoxContainer/highest_score/value
@onready var spent_score : Label = $records_page/VBoxContainer/spent_score/value
@onready var times_played : Label = $records_page/VBoxContainer/times_played/value
@onready var burgers_served : Label = $records_page/VBoxContainer/burgers_served/value
@onready var savings_transfer : Control = $savings_transfer
#var loaded_stats : Play.Stats


func _ready() -> void:
	savings_transfer.hide()


func ready_records() -> void:
	records_page.show()
	savings_transfer.hide()
	$records_page/controls/back_button.grab_focus()


func assign_stats(stats : Play.Stats) -> void:
	#loaded_stats = stats
	total_score.text = "$" + str(stats.total_score)
	highest_score.text = "$" + str(stats.highest_score)
	spent_score.text = "$" + str(stats.total_score - stats.spent_score)
	times_played.text = str(stats.times_played)
	var total : int = 0
	for cs in stats.customer_stats:
		total += cs.orders_served
	burgers_served.text = str(total)


func _on_button_press(button : String) -> void:
	if button == "back":
		emit_signal("close_records")
	elif button == "savings":
		print("Open Savings")
	elif button == "trash":
		print("Open Trash")
