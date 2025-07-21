extends Node2D
class_name Kitchen

signal customer_ready()
signal customer_left()

@export var customer_burger_portal : BurgerPortal
@export var customers_node : Node2D
@export var normy_customers : Array[Customer] = []
@export var splat : AnimatedSprite2D
var customers : Array[Customer] = []
var queue : PackedInt32Array = []
var queue_idx : int = 0
var current_customer : Customer = null
var next_customer : Customer = null


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
	prep_kitchen()


func prep_kitchen():
	print("Prep Kitchen Called")
	for c in customers:
		c.hide()
	splat.hide()
	if current_customer != null:
		current_customer.sound_player.stop()
	queue_idx = -1
	current_customer = null
	next_customer = null
	for c in customers:
		c.current_customer = false
		c.status = Customer.CUSTOMER_STATE.Gone
	_build_queue()


func _build_queue():
	queue.clear()
	
	## Filter through for eligible special customers
	var eligible_pool : Array[Customer] = []
	for c in customers:
		##
		## REPLACE WITH : IF ELIGIBLE TIME SLOT
		##
		if !normy_customers.has(c):
			eligible_pool.append(c)
	print("Eligible Unique Customers Size: ", eligible_pool.size())
	
	randomize()
	for i in 30:
		print("Queue Build, ", i)
		if randf() <= 0.5:
			print("Tossing in a normy")
			if queue.size() > 0:
				print("Queue Larger than 0")
				var filter_repeats = []
				for n in normy_customers:
					var normy_idx = customers.find(n)
					var queue_last = queue[queue.size() - 1]
					if normy_idx != queue_last:
						print(normy_idx, " doesn't equal ", queue_last)
						filter_repeats.append(n)
				print("Filtered Out non-repetitive normies :\n", filter_repeats)
				queue.append(customers.find(filter_repeats.pick_random()))
			else:
				queue.append(customers.find(normy_customers.pick_random()))
		else:
			if eligible_pool.size() > 0:
				print("Tossing in a unique customer")
				var unique_customer : Customer = eligible_pool.pick_random()
				var idx = customers.find(unique_customer)
				if unique_customer.consecutive_orders > 1:
					for x in unique_customer.consecutive_orders:
						queue.append(idx)
						queue.append(customers.find(normy_customers.pick_random()))
				else:
					queue.append(idx)
			else:
				print("No Unique Customers are eligible...")



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

	#current_customer.play_greeting()
	print("Current_customer : ", current_customer.customer_name)
	print("Current_Customer New Order\n\n", result)
	
	return result


func play_splat(pos : Vector2):
	splat.position = pos
	splat.show()
	splat.play("splat")
	splat.get_child(0).play()


func _on_splat_animation_finished():
	splat.hide()


func customer_fed(meal_rank : int):
	print("Customer Fed with Meal Rank: ", meal_rank)
	var options = [
		"feedback_disappointed",
		"feedback_satisfactory",
		"feedback_fantastic"
	]
	current_customer.target_feedback_anim = options[meal_rank - 1]
	current_customer.set_state(Customer.CUSTOMER_STATE.Munching)


func _on_customer_arrived():
	print("Kitchen Customer has Arrived")
	emit_signal("customer_ready")
	if next_customer.status == Customer.CUSTOMER_STATE.Gone \
	or next_customer.status < Customer.CUSTOMER_STATE.Queue:
		next_customer.set_state(Customer.CUSTOMER_STATE.Entering)


func _on_customer_leaving():
	print("Kitchen: Customer is leaving... queue next!")
	readying_next_customer()


func _on_customer_finished():
	print("Kitchen Acknowledges the Customer is Gone")
	emit_signal("customer_left")
