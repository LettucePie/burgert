extends Control
class_name Help

@onready var title : Label = $InfoPanel/VBoxContainer/title
@onready var page : Label = $InfoPanel/VBoxContainer/page

@onready var controls : Control = $Controls
@onready var close_but : Button = $Controls/close
@onready var next_but : Button = $Controls/next
@onready var prev_but : Button = $Controls/prev

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

var current_page : int = 0

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

func start_page():
	current_page = 0
	_load_page(0)


func _load_page(num : int):
	current_page = num
	title.text = titles[current_page]
	page.text = pages[current_page]
	close_but.hide()
	prev_but.show()
	next_but.show()
	if current_page <= 0:
		close_but.show()
		controls.move_child(close_but, 0)
		prev_but.hide()
		next_but.show()
		controls.move_child(next_but, 1)
		next_but.grab_focus()
	if current_page > 0 and current_page < titles.size() - 1:
		close_but.hide()
		controls.move_child(close_but,3)
		prev_but.show()
		controls.move_child(prev_but,0)
		next_but.show()
		controls.move_child(next_but, 1)
		controls.move_child(close_but, 2)
	if current_page == titles.size() - 1:
		next_but.hide()
		controls.move_child(next_but, 3)
		close_but.show()
		prev_but.show()
		controls.move_child(prev_but, 0)
		controls.move_child(close_but, 1)
		controls.move_child(next_but, 2)
		prev_but.grab_focus()


func _turn_page(dir : int):
	print("Turning Page: ", dir)
	if current_page + dir < titles.size() \
	and current_page + dir >= 0:
		_load_page(current_page + dir)


func _ready() -> void:
	start_page()
