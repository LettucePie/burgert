extends Node2D
class_name Kitchen

@export var customer_burger_portal : BurgerPortal
@export var customers_node : Node2D
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
	for c in customers:
		c.hide()


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
	result = current_customer.orders.pick_random()
	customer_burger_portal.burger.assemble_burger_build(result)
	current_customer.play_greeting()
	print("Current_Customer New Order\n\n", result)
	
	return result


func reveal_customer(customer : Customer):
	for c in customers:
		c.hide()
	customer.show()
