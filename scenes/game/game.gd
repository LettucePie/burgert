extends Node
class_name Game

signal game_paused()

@export var kitchen : Node2D
@export var hud : HUD
@export var chef : Chef
#@export var chef_scene : PackedScene
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
	chef.current_burger.refresh_plate()
	hud.show()
	$game_timer.start(120)
	hud.set_timer($game_timer)
	make_new_order()


func stop_game():
	if game_started:
		chef.current_burger.refresh_plate()
		chef.position.x = 0
	game_started = false
	hud.hide()
	$game_timer.stop()


func make_new_order():
	current_order.clear()
	current_order = generate_order(1)
	hud.push_burger_build(current_order)
	chef.order_size = current_order.size()
	print("TODO replace with throw-away burger anim + function")
	chef.current_burger.refresh_plate()


func generate_order(difficulty : int) -> PackedStringArray:
	var build : PackedStringArray
	
	randomize()
	build.append("Bun Bottom")
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
