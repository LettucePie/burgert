extends Node
class_name Game

signal game_paused()

@export var kitchen : Kitchen
@export var hud : HUD
@export var chef : Chef
@export var submit : Submit
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
var current_order_position : int = 0
var current_score : int = 0
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


func start_game():
	game_started = true
	current_score = 0
	chef.reset_chef()
	submit.set_playing(false, 0)
	hud.show()
	$game_timer.start(120)
	hud.set_timer($game_timer)
	hud.set_score(current_score)
	make_new_order()


func stop_game():
	if game_started:
		chef.reset_chef()
		submit.set_playing(false, 0)
	game_started = false
	hud.hide()
	$game_timer.stop()


func adjust_score(arg : int):
	current_score += arg
	hud.set_score(current_score)
	print("Adding ", arg, " points")


func make_new_order():
	current_order.clear()
	current_order = generate_order(1)
	current_order_position = randi_range(0, 3)
	hud.push_burger_build(current_order, current_order_position)
	chef.order_size = current_order.size()
	print("TODO replace with throw-away burger anim + function")
	chef.current_burger.refresh_plate()
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
	for i in current_order.size():
		var a = current_order[i]
		var b = "invalid"
		if submission.size() >= i + 1:
			b = submission[i]
		print("[",i,"]: ", a, " | ", b)
		if current_order.has(b) and correct_ingredient_storage.has(b):
			correct_ingredients += 1
			correct_ingredient_storage.remove_at(correct_ingredient_storage.find(b))
		if a == b:
			correct_placements += 3
		else:
			correct_placements = abs(correct_placements - 3)
	var finish_time : float = $game_timer.time_left
	var time_performance = inverse_lerp(0, 12, current_order_start_time - finish_time)
	var time_multiplier = order_point_time_curve.sample(time_performance)
	print("SCORE Asessment: \ncorrect_ingredients: ", correct_ingredients, 
	"\ncorrect_placements: ", correct_placements,
	"\ntime_performance: ", time_performance,
	"\ntime_multiplier: ", time_multiplier)
	submission_total = int((correct_ingredients + correct_placements) * time_multiplier)
	adjust_score(submission_total)
	make_new_order()


func _on_chef_start_burger_submission():
	submit.set_playing(true, chef.position.x)


func _on_chef_cancel_burger_submission():
	submit.set_playing(false, 0)


func _on_chef_submit_burger():
	if submit.current_area_idx == current_order_position:
		print("Successful Throw")
		assess_submission()
	else:
		print("Failed Throw")
	chef.current_burger.refresh_plate()
	chef.submitting_burger = false
	submit.set_playing(false, 0)
