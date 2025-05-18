extends Control
class_name HUD

var order_shown : bool = false
var timer : Timer = null

@onready var target_burger : Burger = $burger_portal.burger
@onready var scribbles : VBoxContainer = $order/VBoxContainer
@onready var top_tear : TextureRect = $order/VBoxContainer/top
@onready var bot_tear : TextureRect = $order/VBoxContainer/bot
@export var entry_scene : PackedScene
@export var top_tears : Array[Texture2D]
@export var bot_tears : Array[Texture2D]

@export var bun_scribbles : Array[Texture2D]
@export var meat_scribbles : Array[Texture2D]
@export var lettuce_scribbles : Array[Texture2D]
@export var tomato_scribbles : Array[Texture2D]
@export var cheese_scribbles : Array[Texture2D]
@export var ketchup_scribbles : Array[Texture2D]
@export var mustard_scribbles : Array[Texture2D]

@onready var customer_spots : Array[TextureRect] = [
	$spot_1, $spot_2, $spot_3, $spot_4
]
@onready var goal_points : Array[TextureRect] = [
	$thought_1/goal, $thought_2/goal, $thought_3/goal, $thought_4/goal
]


func clear_order():
	for gp in goal_points:
		gp.get_parent().hide()
	for cs in customer_spots:
		cs.hide()
	top_tear.reparent(self)
	top_tear.hide()
	bot_tear.reparent(self)
	bot_tear.hide()
	for child in scribbles.get_children():
		child.queue_free()
	$order.scroll_vertical = 0


func _build_order(build):
	clear_order()
	randomize()
	top_tear.reparent(scribbles)
	top_tear.visible = true
	top_tear.texture = top_tears[randi_range(0, 1)]
	for b in build:
		var new_entry : ScribbleEntry = entry_scene.instantiate()
		scribbles.add_child(new_entry)
		if b.contains("Bun"):
			new_entry.scribble.texture = bun_scribbles.pick_random()
		if b.contains("Meat"):
			new_entry.scribble.texture = meat_scribbles.pick_random()
		if b.contains("Lettuce"):
			new_entry.scribble.texture = lettuce_scribbles.pick_random()
		if b.contains("Tomato"):
			new_entry.scribble.texture = tomato_scribbles.pick_random()
		if b.contains("Cheese"):
			new_entry.scribble.texture = cheese_scribbles.pick_random()
		if b.contains("Ketchup"):
			new_entry.scribble.texture = ketchup_scribbles.pick_random()
		if b.contains("Mustard"):
			new_entry.scribble.texture = mustard_scribbles.pick_random()
	bot_tear.reparent(scribbles)
	bot_tear.visible = true
	bot_tear.texture = bot_tears[randi_range(0, 1)]


func show_order(tf : bool):
	order_shown = tf
	$order.visible = tf


func push_burger_build(build : PackedStringArray, goal_idx : int):
	target_burger.assemble_burger_build(build)
	_build_order(build)
	customer_spots[goal_idx].show()
	goal_points[goal_idx].get_parent().show()


func set_score(arg : int):
	$VBoxContainer/score.text = "SCORE " + str(arg)


func set_timer(t : Timer):
	timer = t


func get_timer() -> Timer:
	return timer


# Called when the node enters the scene tree for the first time.
func _ready():
	for g in goal_points:
		g.texture.viewport_path = "burger_portal"
	$order.hide()


func process_scrolling(delta):
	if Input.is_action_just_pressed("up"): $order.scroll_vertical -= 64
	if Input.is_action_just_pressed("down"): $order.scroll_vertical += 64


func _physics_process(delta):
	if order_shown:
		process_scrolling(delta)
	if timer != null:
		$VBoxContainer/time.text = "TIME - " + str(floor(timer.time_left))
