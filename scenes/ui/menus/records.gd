extends Control
class_name Records

signal close_records()

@onready var anim : AnimationPlayer = $AnimationPlayer

## Records Page
@onready var records_page : Control = $records_page
@onready var total_score : Label = $records_page/VBoxContainer/total_score/value
@onready var highest_score : Label = $records_page/VBoxContainer/highest_score/value
@onready var spent_score : Label = $records_page/VBoxContainer/spent_score/value
@onready var times_played : Label = $records_page/VBoxContainer/times_played/value
@onready var burgers_served : Label = $records_page/VBoxContainer/burgers_served/value
@onready var savings_transfer : Control = $savings_transfer

## Savings Transfer
@onready var digits : Array[Label] = [
	$"savings_transfer/Vbox/teller/counter/1",
	$"savings_transfer/Vbox/teller/counter/2",
	$"savings_transfer/Vbox/teller/counter/3",
	$"savings_transfer/Vbox/teller/counter/4",
	$"savings_transfer/Vbox/teller/counter/5",
	$"savings_transfer/Vbox/teller/counter/6"
]
var transfer_amount : int = 0
var tick : int = 0
var transfer_offset : int = 0
var tick_rate : int = 0


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


func _physics_process(delta: float) -> void:
	if transfer_offset != 0:
		tick += 1
		if tick >= tick_rate:
			transfer_amount = clampi(transfer_amount + transfer_offset, 0, 999999)
			tick = 0
			tick_rate = clampi(tick_rate - 2, 6, 60)


func _adjust_transfer_amount(dir : int) -> void:
	if dir > 0:
		transfer_offset = 1
	elif dir < 0:
		transfer_offset = -1
	elif dir == 0:
		transfer_offset = 0
	tick_rate = 60
	tick = 0
