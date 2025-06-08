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
	for c in customers:
		c.hide()


func pick_customer() -> PackedStringArray:
	var result : PackedStringArray = []
	
	## Deliberate which Customer to randomly pick.
	randomize()
	if current_customer == null:
		current_customer = customers.pick_random()
	else:
		## Cleanup Previous Customer
		past_customers.append(current_customer)
		current_customer.hide()
		
		if current_customer.consecutive_orders > 1 \
		and past_customers.size() >= current_customer.consecutive_orders:
			var satisfied : bool = true
			for i in current_customer.consecutive_orders:
				var index : int = past_customers.size() - (i + 1)
				if past_customers[index] != current_customer:
					satisfied = false
			if satisfied:
				var altered_list : Array[Customer] = customers.duplicate()
				altered_list.erase(current_customer)
				current_customer = altered_list.pick_random()
		else:
			current_customer = customers.pick_random()
	
	## Pick one of their orders randomly.
	current_customer.show()
	result = current_customer.orders.pick_random()
	customer_burger_portal.burger.assemble_burger_build(result)
	
	return result


func reveal_customer(customer : Customer):
	for c in customers:
		c.hide()
	customer.show()
