extends Node2D
class_name Kitchen

@export var customer_burger_portal : BurgerPortal
@export var customers_node : Node2D
var customers : Array[Customer] = []

func _ready():
	## build customer list
	customers.clear()
	for child in customers_node.get_children():
		if child is Customer:
			customers.append(child)
	for c in customers:
		c.hide()


func push_burger_build(build : PackedStringArray):
	pass


func reveal_customer(customer : Customer):
	for c in customers:
		c.hide()
	customer.show()
