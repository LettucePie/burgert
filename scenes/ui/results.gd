extends Control
class_name Results

signal finished_results()

@onready var order_count : Label = $Panel/ordercount
@onready var accuracy : Label = $Panel/accuracy
@onready var score : Label = $Panel/score
@onready var finish_button : Button = $Panel/finish

var stat_order_count : int = 0
var accuracy_percent : float = 0.0
var score_total : int = 0

@onready var anim_tree : AnimationTree = $AnimationTree
@onready var anim_play : AnimationPlayer = $AnimationPlayer
var anim_state : AnimationNodeStateMachinePlayback
var animating : bool = false
var animation_step : int = 0


##TESTING
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_SPACE and OS.has_feature("editor"):
			print("RUNNING TEST")
			display_results(
				PackedFloat32Array([0.333, 0.5, 0.1, 1.0, 0.5, 0.67, 0.8, 0.333]), 
				randi_range(5, 100))


func _ready():
	if anim_tree.anim_player != anim_play.get_path():
		anim_tree.anim_player = anim_play.get_path()
	anim_state = anim_tree.get("parameters/playback")
	self.hide()


func display_results(accuracies : PackedFloat32Array, game_score : int):
	#order_count.text = str(accuracies.size())
	stat_order_count = 0
	accuracy_percent = 0.0
	score_total = game_score
	##
	stat_order_count = accuracies.size()
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
	anim_state.travel("alarm")
	#anim_play.play("alarm")
	#anim_tree.trav
	#anim_tree.


func _on_finish_pressed():
	if !animating:
		emit_signal("finished_results")


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	print("Animation Finished: ", anim_name)
	if anim_name == "alarm":
		anim_state.travel("panel_enter")
