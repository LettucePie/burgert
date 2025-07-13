extends Node2D
class_name Kitchen

signal customer_ready()
signal customer_left()

@export var customer_burger_portal : BurgerPortal
@export var customers_node : Node2D
@export var splat : AnimatedSprite2D
var customers : Array[Customer] = []
var current_customer : Customer = null
var past_customers : Array[Customer]


func _ready():
	## build customer list
	customers.clear()
	for child in customers_node.get_children():
		if child is Customer:
			customers.append(child)
			child.burger_portal_sprite.texture.viewport_path = customer_burger_portal.get_path()
	prep_kitchen()


func prep_kitchen():
	for c in customers:
		c.hide()
		c.reset()
	splat.hide()
	past_customers.clear()
	if current_customer != null:
		current_customer.munch.stop()
		current_customer.sound_player.stop()
	current_customer = null


func pick_customer() -> PackedStringArray:
	var result : PackedStringArray = []
	print("kitchen.pick_customer() Called")
	print("Current_Customer == ", current_customer)
	## Deliberate which Customer to randomly pick.
	randomize()
	if current_customer == null:
		current_customer = customers.pick_random()
	else:
		## Cleanup Previous Customer
		past_customers.append(current_customer)
		current_customer.hide()
		#current_customer.set_active(false)
		if current_customer.consecutive_orders > 1:
			print(current_customer.customer_name, " Consecutive: ", current_customer.consecutive_orders)
			var satisfied : bool = true
			for i in current_customer.consecutive_orders:
				var index : int = past_customers.size() - (i + 1)
				if index >= 0:
					print("Checking index[", index, "] of past_customers.size(): ", past_customers.size())
					if past_customers[index] != current_customer:
						satisfied = false
				else:
					satisfied = false
			if satisfied:
				print("Current Consecutive Customer is satisfied")
				var altered_list : Array[Customer] = customers.duplicate(true)
				altered_list.erase(current_customer)
				current_customer = altered_list.pick_random()
			else:
				print("Current Consecutive Customer is NOT YET satisfied")
		else:
			current_customer = customers.pick_random()
	
	## Pick one of their orders randomly.
	print("Deliberation Result Current Customer = ", current_customer)
	current_customer.show()
	var out : String = "Current_Customer order options:\n"
	for psa in current_customer.orders:
		for order in psa:
			out += order + ", "
		out += "\n"
	print(out)
	result = current_customer.orders.pick_random().duplicate()
	customer_burger_portal.burger.assemble_burger_build(result)
	current_customer.set_state(Customer.CUSTOMER_STATE.Entering)
	if !current_customer.customer_arrived.is_connected(_on_customer_arrived):
		current_customer.customer_arrived.connect(_on_customer_arrived)
	if !current_customer.customer_finished.is_connected(_on_customer_finished):
		current_customer.customer_finished.connect(_on_customer_finished)
	#current_customer.play_greeting()
	print("Current_Customer New Order\n\n", result)
	
	return result


func play_splat(pos : Vector2):
	splat.position = pos
	splat.show()
	splat.play("splat")
	splat.get_child(0).play()


func _on_splat_animation_finished():
	splat.hide()


func customer_fed():
	if current_customer.status == Customer.CUSTOMER_STATE.Waiting:
		current_customer.set_state(Customer.CUSTOMER_STATE.Munching)


func _on_customer_arrived():
	print("Kitchen Customer has Arrived")
	emit_signal("customer_ready")



func _on_customer_finished():
	print("Kitchen Acknowledges the Customer is Gone")
	emit_signal("customer_left")
