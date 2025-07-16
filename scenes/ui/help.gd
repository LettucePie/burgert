extends Control
class_name Help

@export var titles : PackedStringArray = [
	"Goal",
	"Controls",
	"Making The Order",
	"Submitting The Order",
	"Scoring Points"
]
@export var pages : PackedStringArray = [
	"Make the orders for the Customers as quick and accurate as you can.\
	Then throw them their meal and start up the next order. You get 2 \
	minutes!",
	"Movement - Left and Right\nGrab Ingredients - A (Z on Keyboard)\nRestart\
	 - Hold B (X on Keyboard)\nCheck the Order Receipt - Y (C on Keyboard)\n\
	Submit Order Mode - Up",
	"Start by Checking the Order or just use the model in the thought cloud.\
	Then simply gather the ingredients in that order and send it away.\
	Customers have preferred orders, so you can develop a pattern over time.",
	"You cannot submit an order until it has the same amount of Ingredients \
	as what the customer is ordering. Once that's set you enter \"Throwing Mode\"\
	with the Submit button. Then when the reticle is over the customer press \
	the submit button again or the primary Confirm button.",
	"Points are calculated by how many of the desired Ingredients are on the \
	order, as well as how they are sequenced. Then that score is scaled by \
	how long it took to submit it. Send an order that's completely wrong, and \
	you may lose points."
]

####
#### Mutli-Lang Help Setters
####
func set_titles(strings : Array):
	titles.clear()
	for s in strings:
		if s is String:
			titles.append(s)

func set_pages(strings : Array):
	pages.clear()
	for s in strings:
		if s is String:
			pages.append(s)

####
#### End Multi-Lang Help Setters
####

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
