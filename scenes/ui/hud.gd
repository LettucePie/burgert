extends Control
class_name HUD

signal gui_pause()

@onready var anim : AnimationPlayer = $AnimationPlayer
var order_shown : bool = false
var order_dithered : bool = false
var order_dither_buffer : int = 60
@export var dithered_color : Color
var timer : Timer = null

@onready var time : Label = $stats/frame/time
@onready var score : Label = $stats/frame/score
@onready var tip : AnimatedSprite2D = $tip
@onready var submission_pop : SubmissionPop = $submission_pop

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

@onready var order : Control = $order
@onready var trash_bar : TextureProgressBar = $trash_bar
@onready var oink : AnimatedSprite2D = $oink
@onready var money_spray : CPUParticles2D = $money_spray
@onready var flash : ColorRect = $flash
@onready var camera_shutter : AudioStreamPlayer = $flash/camera_shutter

##

var pending_score : int = -1
var ticking_score : bool = false
var current_score : int = 0
var target_score : int = 0
var offset : int = 1
var tick : int = 0
const TWEEN_SPEED : float = 0.06

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
	order.scroll_vertical = 0


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
	order.visible = tf
	if tf:
		order_dither_buffer = 10
	dither_order(false)


func dither_order(tf : bool):
	order_dithered = tf


func push_burger_build(build : PackedStringArray):
	_build_order(build)


func print_popup_receipt(tip_amount : int):
	pending_score += tip_amount
	submission_pop.set_total(pending_score)
	submission_pop.popup()


## Sets the Target Score to a value, then decides if the ticker effect
## needs to go positive or negative.
func set_score(arg : int):
	target_score = arg
	offset = 1
	if target_score < current_score:
		offset = -1
	tick = 0
	ticking_score = target_score != current_score


func set_timer(t : Timer):
	timer = t


func get_timer() -> Timer:
	return timer


# Called when the node enters the scene tree for the first time.
func _ready():
	order.hide()
	trash_bar.hide()
	tip.hide()
	submission_pop.hide()
	oink.hide()
	money_spray.hide()


func reset_score() -> void:
	pending_score = -1
	ticking_score = false
	current_score = 0
	target_score = 0


func process_scrolling(delta):
	if Input.is_action_just_pressed("up"): order.scroll_vertical -= 64
	if Input.is_action_just_pressed("down"): order.scroll_vertical += 64


func _tween_score_counter(pos : bool) -> void:
	var tween : Tween = create_tween()
	var target : Vector2 = Vector2(175.58, 0)
	var rot : float = 0.0
	var sca : Vector2 = Vector2.ONE
	var colo : Color = Color.WHITE
	score.position = score.position + Vector2(randf_range(-1.5, 1.5), randf_range(-0.5, 0.5))
	score.rotation = randf_range(-0.12, 0.12)
	score.scale = Vector2(1.25, 1.25)
	score.self_modulate = Color.GREEN
	if !pos:
		score.self_modulate = Color.RED
	tween.tween_property(score, "position", target, TWEEN_SPEED)
	tween.set_parallel()
	tween.tween_property(score, "rotation", rot, TWEEN_SPEED)
	tween.tween_property(score, "scale", sca, TWEEN_SPEED)
	tween.tween_property(score, "self_modulate", colo, TWEEN_SPEED)


func _physics_process(delta):
	if order_shown:
		process_scrolling(delta)
		if order_dithered and order_dither_buffer <= 0:
			order.modulate = order.modulate.lerp(dithered_color, 0.2)
		else:
			order.modulate = order.modulate.lerp(Color.WHITE, 0.2)
		if order_dither_buffer > 0:
			order_dither_buffer -= 1
	if timer != null:
		time.text = str(floor(timer.time_left))
	if ticking_score:
		tick += 1
		if tick > 3:
			current_score += offset
			score.text = str(current_score)
			ticking_score = current_score != target_score
			_tween_score_counter(offset > 0)
			tick = 0
	if flash.visible:
		flash.modulate = flash.modulate.lerp( Color(1, 1, 1, 0.0), 0.24)
		if flash.modulate.is_equal_approx(Color(1, 1, 1, 0.0)):
			flash.hide()


func _on_pause_pressed():
	emit_signal("gui_pause")


func _on_order_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		order.scroll_vertical -= event.relative.y


func start_trashing():
	trash_bar.show()
	trash_bar.value = 0


func update_trashing(val):
	trash_bar.value = val


func trashing_stopped():
	trash_bar.hide()
	trash_bar.value = 0


func _on_submission_pop_receipt_fully_popped() -> void:
	set_score(current_score + pending_score)


func oink_popup() -> void:
	anim.play("oink")


func pop_money() -> void:
	money_spray.show()
	money_spray.restart()


func _on_money_spray_finished() -> void:
	money_spray.hide()


func new_regular_snapped() -> void:
	flash.modulate = Color.WHITE
	flash.show()
	camera_shutter.play()
