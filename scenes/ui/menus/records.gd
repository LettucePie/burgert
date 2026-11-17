extends Control
class_name Records

signal close_records()
signal deposit_to_savings(amount)

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
@onready var transfer_anim : AnimationPlayer = $savings_transfer/transfer_anim
@onready var digits : Array[Label] = [
	$"savings_transfer/counter/1",
	$"savings_transfer/counter/2",
	$"savings_transfer/counter/3",
	$"savings_transfer/counter/4",
	$"savings_transfer/counter/5",
	$"savings_transfer/counter/6"
]
@onready var wallet_label : Label = $savings_transfer/totals/wallet/Label
@onready var bank_label : Label = $savings_transfer/totals/bank/Label
var transfer_amount : int = 0
var tick : int = 0
var transfer_offset : int = 0
var tick_rate : int = 0
var offset_accelerate : int = 5
var scales : PackedInt32Array = [1, 5, 10, 50, 100, 500, 1000, 5000, 10000]
var scale_progress : int = 0
@onready var teller_sfx : AudioStreamPlayer2D = $savings_transfer/teller_sfx
var transfer_max : int = 1000000
var available_transfer : int = 0
var transferring : bool = false
@export var transferring_anim_curve : Curve = null
var transfer_timestop : int = 0
var transfer_timestart : int = 0
var target_wallet : int = 0
var target_bank : int = 0
@onready var money_stream : AnimatedSprite2D = $savings_transfer/money_stream


func _ready() -> void:
	savings_transfer.hide()


func ready_records() -> void:
	records_page.show()
	savings_transfer.hide()
	_set_transfer_buttons_disabled(true)
	$records_page/controls/back_button.grab_focus()


func _set_transfer_buttons_disabled(tf : bool):
	$savings_transfer/counter/teller/minus.disabled = tf
	$savings_transfer/counter/teller/add.disabled = tf
	$savings_transfer/counter/approve/cancel.disabled = tf
	$savings_transfer/counter/approve/submit.disabled = tf


func ready_transfer_menu() -> void:
	records_page.hide()
	transfer_amount = 0
	tick = 0
	transfer_offset = 0
	tick_rate = 0
	offset_accelerate = 5
	transferring = false
	money_stream.hide()
	_apply_transfer_adjustment(0)
	_set_transfer_buttons_disabled(false)
	$savings_transfer/counter/teller/minus.grab_focus()


func assign_stats(stats : Play.Stats) -> void:
	total_score.text = "$" + str(stats.total_score)
	highest_score.text = "$" + str(stats.highest_score)
	spent_score.text = "$" + str(stats.total_score - stats.spent_score)
	saved_score.text = "$" + str(stats.saved_score)
	transfer_max = 1000000 - stats.saved_score
	available_transfer = stats.total_score - stats.spent_score
	times_played.text = str(stats.times_played)
	var total : int = 0
	for cs in stats.customer_stats:
		total += cs.orders_served
	burgers_served.text = str(total)
	wallet_label.text = "$" + str(stats.total_score - stats.spent_score)
	bank_label.text = "$" + str(stats.saved_score)


func _on_button_press(button : String) -> void:
	if button == "back":
		emit_signal("close_records")
	elif button == "savings":
		anim.play("open_transfer_menu")
	elif button == "trash":
		print("Open Trash")


func _apply_transfer_adjustment(scale_idx : int) -> void:
	var adjustment = transfer_offset * scales[scale_idx]
	if transfer_amount + adjustment > available_transfer:
		adjustment = available_transfer - transfer_amount
	if transfer_amount + adjustment > transfer_max:
		adjustment = transfer_max - transfer_amount
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
				teller_sfx.pitch_scale = clampf(teller_sfx.pitch_scale + 0.15, 1.0, 1.6)
	$savings_transfer/counter.rotation = lerp_angle($savings_transfer/counter.rotation, 0, 0.33)
	if transferring:
		var current_time : int = Time.get_ticks_msec()
		var progress : float = inverse_lerp(
			float(transfer_timestart), 
			float(transfer_timestop), 
			float(current_time))
		wallet_label.text = "$" + str(int(lerp(available_transfer, target_wallet, progress)))
		bank_label.text = "$" + str(int(lerp(1000000 - transfer_max, target_bank, progress)))
		if current_time >= transfer_timestop:
			transferring = false
			money_stream.play("end")
			emit_signal("deposit_to_savings", transfer_amount)


func _adjust_transfer_amount(dir : int) -> void:
	if !transferring:
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
	if !transferring:
		anim.play("close_transfer_menu")


func _on_submit_pressed() -> void:
	print("Send Savings: ", transfer_amount)
	_set_transfer_buttons_disabled(true)
	transfer_anim.play("prep_transfer")
	target_wallet = available_transfer - transfer_amount
	target_bank = (1000000 - transfer_max) + transfer_amount


func _on_transfer_anim_animation_finished(anim_name: StringName) -> void:
	if anim_name == "prep_transfer":
		money_stream.show()
		money_stream.play("intro")
	if anim_name == "finish_transfer":
		transferring = false
		_set_transfer_buttons_disabled(false)
		$savings_transfer/counter/approve/cancel.grab_focus()


func _on_money_stream_animation_finished() -> void:
	if money_stream.animation == "intro":
		transferring = true
		transfer_timestart = Time.get_ticks_msec()
		transfer_timestop = transfer_timestart + \
		(6000 * \
		transferring_anim_curve.sample(
		inverse_lerp(0.0, float(transfer_max), float(transfer_amount))))
		money_stream.play("loop")
	if money_stream.animation == "end":
		money_stream.hide()
		transfer_anim.play("finish_transfer")
		transfer_amount = 0
		_apply_transfer_adjustment(0)
