extends Control
class_name Results

signal finished_results()

@onready var order_count : Label = $Panel/ordercount
@onready var accuracy : Label = $Panel/accuracy
@onready var score : Label = $Panel/score
@onready var finish_button : Button = $Panel/finish

@onready var receipt_sprite : Receipt_FX = $assets/receipt_sprite
@onready var receipt_tray : HBoxContainer = $Panel/receipt_tray
var spawning_receipts : bool = false
var spawning_receipt_count : int = -1
var tick : int = 0
@onready var scorelabel : Label = $Panel/scorelabel
@onready var jitter : JitterDialog = $AudioStreamPlayer/JitterDialog
var typing_scorelabel : bool = false
var typing_scorelabel_charcount : int = -1
@onready var money_sprite : Money_FX = $assets/money_sprite
@onready var register : TextureRect = $Panel/register
var counting_money : bool = false
var counting_score : int = 0

var result_accuracies : PackedFloat32Array
var result_scores : PackedInt32Array
var result_order_count : int = 0
var result_percent : float = 0.0
var result_total : int = 0

@onready var anim_play : AnimationPlayer = $AnimationPlayer
var animating : bool = false
var animation_step : int = 0
var timeline : PackedStringArray = [
	"alarm",
	"panel_enter",
	"orders_enter",
	"accuracies_enter",
	"!spawn_receipts",
	"score_enter",
	"register_enter",
	"!count_money",
	"finish_enter",
	"!done"
]


func _ready():
	self.hide()
	$assets.hide()


func _process_receipts() -> void:
	tick += 2
	if tick > 30:
		tick = 0
		if spawning_receipt_count > 0:
			var new_receipt : Receipt_FX = receipt_sprite.duplicate()
			receipt_tray.add_child(new_receipt)
			new_receipt.play_bop()
		var temporary_percent : float = 0.0
		var index = result_order_count - spawning_receipt_count
		if index == 0:
			temporary_percent += result_accuracies[index]
		else:
			for i in index:
				temporary_percent += result_accuracies[i]
			temporary_percent /= index
		if index >= 0 :
			order_count.text = str(index + 1)
			accuracy.text = str(snapped((temporary_percent * 100), 0.01)) + "%"
		spawning_receipt_count -= 1
		if spawning_receipt_count <= 0:
			spawning_receipts = false
			if result_accuracies.size() > 0:
				accuracy.text = str(snapped((result_percent * 100), 0.01)) + "%"
			else:
				order_count.text = "0"
				accuracy.text = "0.0%"
			next_animation_step()


func _process_typing() -> void:
	if typing_scorelabel_charcount != scorelabel.visible_characters:
		typing_scorelabel_charcount = scorelabel.visible_characters
		if scorelabel.text.right(1) != " ":
			jitter.jitter()
		if typing_scorelabel_charcount <= -1:
			typing_scorelabel = false


func _process_money() -> void:
	if result_scores.size() == 0:
		score.text = "$0"
		counting_money = false
		next_animation_step()
	tick += 4
	if tick > 30 and counting_money:
		tick = 0
		var new_money : Money_FX = money_sprite.duplicate()
		register.add_child(new_money)
		if result_scores[spawning_receipt_count] > 0:
			new_money.play_anim("add")
		else:
			new_money.play_anim("subtract")
		counting_score += result_scores[spawning_receipt_count]
		score.text = "$" + str(counting_score)
		spawning_receipt_count += 1
		if spawning_receipt_count >= result_order_count:
			counting_money = false
			next_animation_step()


func _physics_process(delta: float) -> void:
	if spawning_receipts and spawning_receipt_count >= 0:
		_process_receipts()
	if typing_scorelabel:
		_process_typing()
	if counting_money and spawning_receipt_count >= 0:
		_process_money()


func display_results(accuracies : PackedFloat32Array, scores : PackedInt32Array):
	#order_count.text = str(accuracies.size())
	result_accuracies = accuracies
	result_percent = 0.0
	result_scores = scores
	result_total = 0
	spawning_receipts = false
	spawning_receipt_count = -1
	typing_scorelabel = false
	counting_money = false
	for child in receipt_tray.get_children():
		child.queue_free()
	for child in register.get_children():
		child.queue_free()
	##
	result_order_count = accuracies.size()
	for a in accuracies:
		result_percent += a
	result_percent /= accuracies.size()
	order_count.text = "-"
	accuracy.text = "-"
	score.text = "-"
	for val in scores:
		result_total += val
	self.show()
	animating = true
	animation_step = 0
	#finish_button.grab_focus()
	anim_play.play("alarm")


func _on_finish_pressed():
	if !animating:
		emit_signal("finished_results")
		anim_play.play("panel_exit")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name != "panel_exit":
		next_animation_step()


func next_animation_step():
	var next = animation_step + 1
	if !timeline[next].contains("!"):
		anim_play.play(timeline[next])
	else:
		if timeline[next] == "!spawn_receipts":
			start_spawning_receipts()
		if timeline[next] == "!count_money":
			start_counting_money()
		if timeline[next] == "!done":
			finish_button.grab_focus()
			animating = false
	animation_step = next


func start_spawning_receipts():
	spawning_receipt_count = result_order_count
	spawning_receipts = true
	tick = 0


func start_typing_scorelabel():
	typing_scorelabel = true
	typing_scorelabel_charcount = scorelabel.visible_characters


func start_counting_money():
	spawning_receipt_count = 0
	counting_score = 0
	counting_money = true
	tick = 0
