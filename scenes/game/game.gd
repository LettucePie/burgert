extends Node
class_name Game

signal game_paused()
signal game_finished(final_score : int)
signal game_over()
signal finished_order(customer_name : String, satisfaction_rank : int)

@export var kitchen : Kitchen
@export var hud : HUD
@export var chef : Chef
@export var submit : Submit
@export var results : Results
@export var order_point_time_curve : Curve
var game_started : bool = false
@onready var bases : PackedStringArray = [
	"Meat", "Bun Bottom", "Cheese"
]
@onready var toppings : PackedStringArray = [
	"Lettuce", "Tomato", "Cheese"
]
@onready var finishes : PackedStringArray = [
	"Cheese", "Mustard", "Ketchup"
]
@export var burger_2d_scene : PackedScene

var current_order : PackedStringArray = []
var current_score : int = 0
var game_accuracies : PackedFloat32Array = []
var game_scores : PackedInt32Array = []
var current_order_start_time : float = 0
var current_order_charging_rate : float = 0.0
var burger_2d : Burger2D = null
var burger_mode_3d : bool = true
var chef_idle : bool = false


func _physics_process(delta):
	if Input.is_action_just_pressed("menu") and game_started:
		hud.show_order(false)
		emit_signal("game_paused")
	if Input.is_action_just_pressed("special1") and game_started:
		if hud.order_shown:
			hud.show_order(false)
		else:
			hud.show_order(true)
		#if chef.active:
			#chef.active = false
			#hud.show_order(true)
		#else:
			#chef.active = true
			#hud.show_order(false)
	if Input.is_action_just_pressed("cancel") and game_started:
		pass
		#if hud.order_shown:
			#chef.active = true
			#hud.show_order(false)
	if chef.idle_counter > 60:
		if !submit.playing and hud.order_dithered:
			hud.dither_order(false)
	elif !hud.order_dithered:
		hud.dither_order(true)
	if Input.is_key_pressed(KEY_F2) and OS.has_feature("editor"):
		$game_timer.start(5)


func _on_chef_chef_ready():
	game_started = true
	hud.show()
	$game_timer.start(120)
	hud.set_timer($game_timer)
	hud.set_score(current_score)
	make_new_order()


func start_game():
	current_score = 0
	game_accuracies.clear()
	game_scores.clear()
	chef.reset_chef()
	chef.burger_portal.set_mode_3D(burger_mode_3d)
	if !kitchen.kitchen_prepped:
		kitchen.prep_kitchen()
	kitchen.customer_burger_portal.set_mode_3D(burger_mode_3d)
	submit.set_playing(false, 0, 0)
	submit.assign_chef(chef)
	results.hide()
	$AnimationPlayer.play("play_transition")


func stop_game(reset : bool):
	if reset:
		chef.reset_chef()
		submit.set_playing(false, 0, 0)
		kitchen.prep_kitchen()
		$AnimationPlayer.play("menu_transition")
	results.hide()
	game_started = false
	hud.hide()
	$game_timer.stop()


func adjust_score(arg : int):
	game_scores.append(arg)
	current_score += arg
	hud.set_score(current_score)


func make_new_order():
	current_order.clear()
	current_order = kitchen.readying_next_customer()
	hud.push_burger_build(current_order)
	chef.order_size = current_order.size()
	chef.current_burger.refresh_plate()
	chef.waiting = true


func _on_kitchen_a_start_timer() -> void:
	current_order_start_time = $game_timer.time_left


func generate_order(difficulty : int) -> PackedStringArray:
	var build : PackedStringArray
	
	randomize()
	build.append("Bun")
	if difficulty <= 1:
		build.append(bases[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(finishes[randi_range(0,2)])
	elif difficulty == 2:
		build.append(bases[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(finishes[randi_range(0,2)])
	elif difficulty == 3:
		build.append(bases[randi_range(0,2)])
		build.append(bases[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(finishes[randi_range(0,2)])
	elif difficulty == 4:
		build.append(bases[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(bases[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(toppings[randi_range(0,2)])
		build.append(finishes[randi_range(0,2)])
	build.append("Bun Top")
	
	return build


func assess_submission():
	var submission : PackedStringArray = chef.current_burger.ingredients
	var submission_total : int = 0
	var correct_ingredient_storage : PackedStringArray = current_order.duplicate()
	var correct_ingredients : int = 0
	var correct_placements : int = 0
	var wrong_ingredients : int = 0
	for i in current_order.size():
		var a = current_order[i]
		var b = "invalid"
		if submission.size() >= i + 1:
			b = submission[i]
		if current_order.has(b) and correct_ingredient_storage.has(b):
			correct_ingredients += 1
			correct_ingredient_storage.remove_at(correct_ingredient_storage.find(b))
		else:
			wrong_ingredients += 1
		if a == b:
			correct_placements += 1
	var burger_score : int = (correct_ingredients + correct_placements) - wrong_ingredients
	var finish_time : float = current_order_start_time - $game_timer.time_left
	var deadline : float = 6 + (current_order.size() * 1.45)
	var time_performance = inverse_lerp(0, deadline, finish_time)
	var time_percent = order_point_time_curve.sample(time_performance)
	var time_score := roundf((current_order.size() - wrong_ingredients) * time_percent)
	var satisfaction_percent : float = float(time_score) / float(current_order.size())
	var charge_throw : float = lerpf(1.0, 2.0, 
		inverse_lerp(
		chef.charging_rate_min, chef.charging_rate_max, 
		current_order_charging_rate
		))
	submission_total = (burger_score + time_score) * charge_throw
	adjust_score(submission_total)
	var accuracy = float(correct_placements) / float(current_order.size())
	game_accuracies.append(accuracy)
	var rank = 1
	if satisfaction_percent > 0.5:
		rank = 2
	if satisfaction_percent > 0.9:
		rank = 3
	emit_signal("finished_order", kitchen.current_customer.customer_name, rank)
	kitchen.customer_fed(rank)
	chef.waiting = true


func _on_chef_start_burger_submission():
	var travel_dir : int = 1
	if chef.direction == "L":
		travel_dir = -1
	submit.set_playing(true, chef.position.x, travel_dir)


func _on_chef_cancel_burger_submission():
	submit.set_playing(false, 0, 0)


func _throw_burger_2d_at(target : Vector2) -> void:
	if burger_2d != null:
		burger_2d.queue_free()
		burger_2d = null
	burger_2d = burger_2d_scene.instantiate()
	self.add_child(burger_2d)
	burger_2d.reached_target.connect(_on_burger_2d_reached_target)
	burger_2d.build_burger(chef.current_burger.ingredients.duplicate())
	burger_2d.position = chef.burger_sprite.global_position
	burger_2d.set_target(target, current_order_charging_rate)


func _on_burger_2d_reached_target(target) -> void:
	if submit.check_customer(kitchen.current_customer):
		assess_submission()
	else:
		kitchen.play_splat(submit.get_target_position())
	chef.current_burger.refresh_plate()
	chef.burger_sprite.show()
	chef.submitting_burger = false


func _on_chef_submit_burger():
	current_order_charging_rate = chef.charging_rate
	_throw_burger_2d_at(submit.get_target_position())
	chef.burger_sprite.hide()
	submit.set_playing(false, 0, 0)


func _on_game_timer_timeout():
	$game_timer.stop()
	game_started = false
	chef.active = false
	chef.submitting_burger = false
	hud.show_order(false)
	submit.set_playing(false, 0, 0)
	results.display_results(game_accuracies, game_scores)
	emit_signal("game_finished", current_score)


func _on_results_finished_results():
	emit_signal("game_over")


func _on_kitchen_a_customer_ready():
	chef.waiting = false


func _on_kitchen_a_customer_left():
	make_new_order()


func _on_kitchen_a_customer_reorder(new_order : PackedStringArray) -> void:
	current_order.clear()
	current_order = new_order
	hud.push_burger_build(current_order)
	chef.order_size = current_order.size()


func _on_hud_gui_pause():
	if game_started:
		emit_signal("game_paused")
		hud.show_order(false)


func _on_chef_trashing_start() -> void:
	hud.start_trashing()


func _on_chef_trashing_progress(val: Variant) -> void:
	hud.update_trashing(val)


func _on_chef_trashing_stopped() -> void:
	hud.trashing_stopped()
