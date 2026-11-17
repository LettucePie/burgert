extends Control
class_name Records

signal close_records()

@onready var anim : AnimationPlayer = $AnimationPlayer

## Records Page
@onready var records_page : Control = $records_page
@onready var total_score : Label = $records_page/VBoxContainer/total_score/value
@onready var highest_score : Label = $records_page/VBoxContainer/highest_score/value
@onready var spent_score : Label = $records_page/VBoxContainer/spent_score/value
@onready var saved_score : Label = $records_page/VBoxContainer/saved_score/value
@onready var times_played : Label = $records_page/VBoxContainer/times_played/value
@onready var burgers_served : Label = $records_page/VBoxContainer/burgers_served/value
@onready var savings_transfer : Control = $savings_transfer

## Savings Transfer
@onready var digits : Array[Label] = [
	$"savings_transfer/counter/1",
	$"savings_transfer/counter/2",
	$"savings_transfer/counter/3",
	$"savings_transfer/counter/4",
	$"savings_transfer/counter/5",
	$"savings_transfer/counter/6"
]
var transfer_amount : int = 0
var tick : int = 0
var transfer_offset : int = 0
var tick_rate : int = 0
var offset_accelerate : int = 5
var scales : PackedInt32Array = [1, 5, 10, 50, 100, 500, 1000, 5000, 10000]
var scale_progress : int = 0
@onready var teller_sfx : AudioStreamPlayer2D = $savings_transfer/teller_sfx
var transfer_max : int = 1000000


func _ready() -> void:
	savings_transfer.hide()


func ready_records() -> void:
	records_page.show()
	savings_transfer.hide()
	$records_page/controls/back_button.grab_focus()


func ready_transfer_menu() -> void:
	records_page.hide()
	transfer_amount = 0
	tick = 0
	transfer_offset = 0
	tick_rate = 0
	offset_accelerate = 5
	_apply_transfer_adjustment(0)
	$savings_transfer/counter/teller/minus.grab_focus()


func assign_stats(stats : Play.Stats) -> void:
	total_score.text = "$" + str(stats.total_score)
	highest_score.text = "$" + str(stats.highest_score)
	spent_score.text = "$" + str(stats.total_score - stats.spent_score)
	saved_score.text = "$" + str(stats.saved_score)
	transfer_max = 1000000 - stats.saved_score
	times_played.text = str(stats.times_played)
	var total : int = 0
	for cs in stats.customer_stats:
		total += cs.orders_served
	burgers_served.text = str(total)


func _on_button_press(button : String) -> void:
	if button == "back":
		emit_signal("close_records")
	elif button == "savings":
		anim.play("open_transfer_menu")
	elif button == "trash":
		print("Open Trash")


func _apply_transfer_adjustment(scale_idx : int) -> void:
	var adjustment = transfer_offset * scales[scale_idx]
	if transfer_amount + adjustment > transfer_max:
		adjustment = (transfer_amount + adjustment) - transfer_max
	transfer_amount = clampi(transfer_amount + adjustment, 0, 999999)
	var label_idx : int = 0
	var amount_str : String = str(transfer_amount)
	amount_str = amount_str.reverse()
	for label in digits:
		label.text = "0"
	for char in amount_str:
		digits[label_idx].text = char
		label_idx += 1
	if adjustment != 0:
		teller_sfx.play()
		$savings_transfer/counter.rotation = randf_range(-0.1, 0.1)


func _physics_process(delta: float) -> void:
	if transfer_offset != 0:
		tick += 1
		if tick >= tick_rate:
			_apply_transfer_adjustment(scale_progress)
			tick = 0
			offset_accelerate -= 1
			if offset_accelerate <= 0:
				offset_accelerate = 5
				tick_rate = clampi(tick_rate - 2, 2, 18)
				scale_progress = clampi(scale_progress + 1, 0, scales.size() - 1)
				teller_sfx.pitch_scale = clampf(teller_sfx.pitch_scale + (transfer_offset * 0.15), -0.6, 1.6)
	$savings_transfer/counter.rotation = lerp_angle($savings_transfer/counter.rotation, 0, 0.33)


func _adjust_transfer_amount(dir : int) -> void:
	if dir > 0:
		transfer_offset = 1
		_apply_transfer_adjustment(0)
	elif dir < 0:
		transfer_offset = -1
		_apply_transfer_adjustment(0)
	elif dir == 0:
		transfer_offset = 0
	tick_rate = 18
	tick = 0
	offset_accelerate = 5
	scale_progress = 0
	teller_sfx.pitch_scale = 1.0


func _on_cancel_pressed() -> void:
	anim.play("close_transfer_menu")


func _on_submit_pressed() -> void:
	print("Send Savings: ", transfer_amount)
