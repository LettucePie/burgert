extends Node2D
class_name Kitchen

signal customer_ready()
signal customer_left()
signal customer_reorder(new_order)
signal start_timer()

@export var customer_burger_portal : BurgerPortal
@export var customers_node : Node2D
@export var normy_customers : Array[Customer] = []
@export var splat : AnimatedSprite2D
@export var workstations : Array[Workstation] = []
@onready var window : AnimatedSprite2D = $window_anim
var customers : Array[Customer] = []
var queue : PackedInt32Array = []
var queue_idx : int = 0
var current_customer : Customer = null
var next_customer : Customer = null
var kitchen_timeslot : int = 0
var kitchen_prepped : bool = false


func _ready():
	## build customer list
	customers.clear()
	for child in customers_node.get_children():
		if child is Customer:
			customers.append(child)
			child.burger_portal_sprite.texture.viewport_path = customer_burger_portal.get_path()
			if !child.customer_arrived.is_connected(_on_customer_arrived):
				child.customer_arrived.connect(_on_customer_arrived)
			if !child.customer_leaving.is_connected(_on_customer_leaving):
				child.customer_leaving.connect(_on_customer_leaving)
			if !child.customer_finished.is_connected(_on_customer_finished):
				child.customer_finished.connect(_on_customer_finished)
			if !child.customer_reorder.is_connected(_on_customer_reorder):
				child.customer_reorder.connect(_on_customer_reorder)
			if !child.start_time.is_connected(_start_timer):
				child.start_time.connect(_start_timer)
			if !child.kitchen_switch.is_connected(_on_kitchen_switch):
				child.kitchen_switch.connect(_on_kitchen_switch)
	customer_burger_portal.set_mode_customer(true)


func prep_kitchen():
	for c in customers:
		c.hide()
	splat.hide()
	_on_kitchen_switch("burgert")
	for w in workstations:
		w.force_hide_magic_pop()
	if current_customer != null:
		current_customer.jitter_dialog.toggle_jitter(false)
		current_customer.sound_player.stop()
	queue_idx = -1
	current_customer = null
	next_customer = null
	for c in customers:
		c.current_customer = false
		c.status = Customer.CUSTOMER_STATE.Gone
	var schedule : Schedule = Schedule.new()
	var timeslot_idx : int = schedule.get_current_timeslot()
	var times_str = ["night", "morning", "noon", "afternoon", "night"]
	window.animation = times_str[timeslot_idx % 4]
	kitchen_prepped = true
	_build_queue()


func _pick_normy() -> int:
	var result : int = customers.find(normy_customers.pick_random())
	if queue.size() > 0:
		var filter_repeats = []
		for n in normy_customers:
			var normy_idx = customers.find(n)
			var queue_last = queue[queue.size() - 1]
			if normy_idx != queue_last:
				filter_repeats.append(n)
		result = customers.find(filter_repeats.pick_random())
	return result


func _check_repeat(subject : int) -> bool:
	var result : bool = false
	if queue.size() > 0:
		result = queue[queue.size() - 1] == subject
	return result


func _pick_unique(pool : Array[Customer]) -> PackedInt32Array:
	var result : PackedInt32Array = [_pick_normy()]
	var unique_customer : Customer = pool.pick_random()
	var idx = customers.find(unique_customer)
	if !_check_repeat(idx):
		if unique_customer.consecutive_orders > 1:
			result.clear()
			for x in unique_customer.consecutive_orders:
				result.append(idx)
				result.append(_pick_normy())
		else:
			result = [idx]
	return result


func _build_queue():
	queue.clear()
	
	## Filter through for eligible special customers
	var eligible_pool : Array[Customer] = []
	kitchen_timeslot = Schedule.new().get_current_timeslot()
	for c in customers:
		if (c.schedule.times.has(kitchen_timeslot) or c.schedule.times.has(0)) \
		and !normy_customers.has(c):
			eligible_pool.append(c)
	
	randomize()
	for i in 38:
		if randf() <= 0.5:
			queue.append(_pick_normy())
		else:
			if eligible_pool.size() > 0:
				queue.append_array(_pick_unique(eligible_pool))
			else:
				queue.append(_pick_normy())



func readying_next_customer() -> PackedStringArray:
	var result : PackedStringArray = []
	queue_idx += 1
	if current_customer != null:
		current_customer.current_customer = false
	else:
		current_customer = customers[queue[queue_idx]]
	if next_customer != null:
		current_customer = next_customer
	next_customer = customers[queue[queue_idx + 1]]
	result = current_customer.orders.pick_random().duplicate()
	customer_burger_portal.burger.assemble_burger_build(result)
	if current_customer.status == Customer.CUSTOMER_STATE.Gone:
		current_customer.set_state(Customer.CUSTOMER_STATE.Entering)
	if current_customer.status == Customer.CUSTOMER_STATE.Queue:
		current_customer.set_state(Customer.CUSTOMER_STATE.Ordering)
	current_customer.current_customer = true
	if next_customer.status == Customer.CUSTOMER_STATE.Gone\
	and current_customer.status > 0:
		next_customer.set_state(Customer.CUSTOMER_STATE.Entering)
	
	return result


func _start_timer():
	emit_signal("start_timer")
	kitchen_prepped = false


func play_splat(pos : Vector2):
	splat.position = pos
	splat.show()
	splat.play("splat")
	splat.get_child(0).play()


func _on_splat_animation_finished():
	splat.hide()


func customer_fed(meal_rank : int):
	var options = [
		"feedback_disappointed",
		"feedback_satisfactory",
		"feedback_fantastic"
	]
	current_customer.target_feedback_anim = options[meal_rank - 1]
	current_customer.set_state(Customer.CUSTOMER_STATE.Munching)


func _on_customer_arrived():
	emit_signal("customer_ready")
	if next_customer.status == Customer.CUSTOMER_STATE.Gone:
		next_customer.set_state(Customer.CUSTOMER_STATE.Entering)


func _on_customer_leaving():
	readying_next_customer()


func _on_customer_finished():
	emit_signal("customer_left")


func _on_customer_reorder():
	var new_order : PackedStringArray = \
	current_customer.orders.pick_random().duplicate()
	emit_signal("customer_reorder", new_order)
	customer_burger_portal.burger.assemble_burger_build(new_order)


func _on_kitchen_switch(target_kitchen):
	for w in workstations:
		w.set_runic(target_kitchen == "runic")
