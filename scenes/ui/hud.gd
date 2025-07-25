extends Control
class_name HUD

signal gui_pause()

var order_shown : bool = false
var timer : Timer = null

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

@onready var trash_bar : TextureProgressBar = $trash_bar

####
#### Multi-Lang Texture Setters
####
func set_bun_scribbles(textures : Array):
	bun_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			bun_scribbles.append(t)

func set_meat_scribbles(textures : Array):
	meat_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			meat_scribbles.append(t)

func set_lettuce_scribbles(textures : Array):
	lettuce_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			lettuce_scribbles.append(t)

func set_tomato_scribbles(textures : Array):
	tomato_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			tomato_scribbles.append(t)

func set_cheese_scribbles(textures : Array):
	cheese_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			cheese_scribbles.append(t)

func set_ketchup_scribbles(textures : Array):
	ketchup_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			ketchup_scribbles.append(t)

func set_mustard_scribbles(textures : Array):
	mustard_scribbles.clear()
	for t in textures:
		if t is Texture2D:
			mustard_scribbles.append(t)

####
#### End Multi-Lang Texture Setters
####

func clear_order():
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


func push_burger_build(build : PackedStringArray):
	_build_order(build)


func set_score(arg : int):
	$VBoxContainer/score.text = "SCORE " + str(arg)


func set_timer(t : Timer):
	timer = t


func get_timer() -> Timer:
	return timer


# Called when the node enters the scene tree for the first time.
func _ready():
	$order.hide()
	trash_bar.hide()


func process_scrolling(delta):
	if Input.is_action_just_pressed("up"): $order.scroll_vertical -= 64
	if Input.is_action_just_pressed("down"): $order.scroll_vertical += 64


func _physics_process(delta):
	if order_shown:
		process_scrolling(delta)
	if timer != null:
		$VBoxContainer/time.text = "TIME - " + str(floor(timer.time_left))


func _on_pause_pressed():
	emit_signal("gui_pause")


func _on_order_gui_input(event: InputEvent) -> void:
	print(event)
	if event is InputEventMouseMotion:
		$order.scroll_vertical -= event.relative.y


func start_trashing():
	trash_bar.show()
	trash_bar.value = 0


func update_trashing(val):
	print("Trashing NewVal: ", val)
	trash_bar.value = val


func trashing_stopped():
	trash_bar.hide()
	trash_bar.value = 0
