extends Node
class_name Game

signal game_paused()
signal game_finished()
signal game_over()

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

var current_order : PackedStringArray = []
var current_score : int = 0
var game_accuracies : PackedFloat32Array = []
var current_order_start_time : float = 0


func _physics_process(delta):
	if Input.is_action_just_pressed("menu"):
		print("PAUSE")
		emit_signal("game_paused")
	if Input.is_action_just_pressed("special1") and game_started:
		if chef.active:
			chef.active = false
			hud.show_order(true)
		else:
			chef.active = true
			hud.show_order(false)
	if Input.is_action_just_pressed("cancel") and game_started:
		if hud.order_shown:
			chef.active = true
			hud.show_order(false)


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
	chef.reset_chef()
	kitchen.prep_kitchen()
	submit.set_playing(false, 0, 0)
	results.hide()
	$AnimationPlayer.play("play_transition")


func stop_game():
	if game_started:
		chef.reset_chef()
		submit.set_playing(false, 0, 0)
		kitchen.prep_kitchen()
		print("Returning to Menu Mode")
		$AnimationPlayer.play("menu_transition")
	results.hide()
	game_started = false
	hud.hide()
	$game_timer.stop()


func adjust_score(arg : int):
	current_score += arg
	hud.set_score(current_score)
	print("Adding ", arg, " points")


func make_new_order():
	current_order.clear()
	#current_order = generate_order(1)
	#current_order_position = randi_range(0, 3)
	current_order = kitchen.pick_customer()
	## TODO transition burger portal display from HUD to Kitchen. Keep Order List
	#kitchen.update_burger_portal()
	#hud.push_burger_build(current_order, current_order_position)
	hud.push_burger_build(current_order)
	chef.order_size = current_order.size()
	print("TODO replace with throw-away burger anim + function")
	chef.current_burger.refresh_plate()
	chef.waiting = true
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
		print("[",i,"]: ", a, " | ", b)
		if current_order.has(b) and correct_ingredient_storage.has(b):
			correct_ingredients += 1
			correct_ingredient_storage.remove_at(correct_ingredient_storage.find(b))
		else:
			wrong_ingredients += 1
		if a == b:
			correct_placements += 1
	var burger_score : int = (correct_ingredients + correct_placements) - wrong_ingredients
	var finish_time : float = current_order_start_time - $game_timer.time_left
	var deadline : float = 6 + (current_order.size() * 1.5)
	var time_performance = inverse_lerp(0, deadline, finish_time)
	var time_percent = order_point_time_curve.sample(time_performance)
	var time_score := int((current_order.size() - wrong_ingredients) * time_percent)
	print("SCORE Asessment: \ncorrect_ingredients: ", correct_ingredients, 
	"\ncorrect_placements: ", correct_placements,
	"\ntime_performance: ", time_performance,
	"\ntime_score: ", time_score)
	submission_total = burger_score + time_score
	adjust_score(submission_total)
	var accuracy = float(correct_placements) / float(current_order.size())
	game_accuracies.append(accuracy)
	kitchen.customer_fed()
	chef.waiting = true
	#make_new_order()


func _on_chef_start_burger_submission():
	var travel_dir : int = 1
	if chef.direction == "L":
		travel_dir = -1
	submit.set_playing(true, chef.position.x, travel_dir)


func _on_chef_cancel_burger_submission():
	submit.set_playing(false, 0, 0)


func _on_chef_submit_burger():
	if submit.check_customer(kitchen.current_customer):
		print("Successful Throw")
		assess_submission()
	else:
		print("Failed Throw")
		kitchen.play_splat(submit.target.position)
	chef.current_burger.refresh_plate()
	chef.submitting_burger = false
	submit.set_playing(false, 0, 0)


func _on_game_timer_timeout():
	$game_timer.stop()
	game_started = false
	chef.active = false
	chef.submitting_burger = false
	hud.show_order(false)
	submit.set_playing(false, 0, 0)
	results.display_results(game_accuracies, current_score)
	emit_signal("game_finished")


func _on_results_finished_results():
	emit_signal("game_over")


func _on_kitchen_a_customer_ready():
	chef.waiting = false


func _on_kitchen_a_customer_left():
	make_new_order()


func _on_hud_gui_pause():
	emit_signal("game_paused")


func _on_chef_trashing_start() -> void:
	hud.start_trashing()


func _on_chef_trashing_progress(val: Variant) -> void:
	hud.update_trashing(val)


func _on_chef_trashing_stopped() -> void:
	hud.trashing_stopped()
