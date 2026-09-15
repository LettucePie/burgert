extends Control
class_name Help

@onready var title : Label = $InfoPanel/title
@onready var page : RichTextLabel = $InfoPanel/page
@onready var guide : AnimatedSprite2D = $InfoPanel/Panel/animated_guide

@onready var controls : Control = $Controls
@onready var close_but : Button = $Controls/close
@onready var next_but : Button = $Controls/next
@onready var prev_but : Button = $Controls/prev

@export var titles : PackedStringArray = [
	"Goal",
	"Controls - Assembly",
	"Controls - Receipt",
	"Controls - Submit",
	"Controls - Charge Throw",
	"Controls - Trashing",
	"Goal - Result",
	"CustomerDex"
]
@export var pages : PackedStringArray = [
	"Make the orders for the Customers as quick and accurate as you can. Then throw them their meal and start up the next order. You get 2 minutes!",
	"Move with the $LEFT or $RIGHT directionals, and assemble the burger by selecting $CONFIRM while standing in front of the ingredient.",
	"The customer will display how they want their burger, or you can double check by reading the receipt with the $RECEIPT button.",
	"Once you're ready, you can enter the throwing position by tapping the $SUBMIT button. When your aim is over the customer, throw the burger with the $CONFIRM button or $SUBMIT button. You can also step back with $CANCEL.",
	"There is a faster way to give the customer their burger, it can earn you more cash too! By holding down the $SUBMIT button instead of tapping, you will charge up your throw. Release $SUBMIT to throw the burger.",
	"If you want to scrap the whole burger, you can do so by holding the $CANCEL button.",
	"Once your 2 minutes are up, the shop closes and your reward gets tallied.",
	"Read through the CustomerDex to check your progress on each of the regulars, or see if they have a chance of showing up today."
]
var guide_names : PackedStringArray = [
	"guide_goal",
	"guide_1",
	"guide_2",
	"guide_3",
	"guide_4",
	"guide_5",
	"guide_results",
	"guide_customerdex"
]
var button_replace_codes : PackedStringArray = [
	"$LEFT",
	"$RIGHT",
	"$CONFIRM",
	"$CANCEL",
	"$RECEIPT",
	"$SUBMIT"
]
var control_pad_paths : PackedStringArray = [
	"res://third-party/kenney-nl/button_icons/tile_0038.png",
	"res://third-party/kenney-nl/button_icons/tile_0036.png",
	"res://third-party/kenney-nl/button_icons/tile_0004.png",
	"res://third-party/kenney-nl/button_icons/tile_0005.png",
	"res://third-party/kenney-nl/button_icons/tile_0006.png",
	"res://third-party/kenney-nl/button_icons/tile_0035.png"
]
var keyboard_paths : PackedStringArray = [
	"res://third-party/kenney-nl/button_icons/tile_0169.png",
	"res://third-party/kenney-nl/button_icons/tile_0167.png",
	"res://third-party/kenney-nl/button_icons/tile_0155.png",
	"res://third-party/kenney-nl/button_icons/tile_0156.png",
	"res://third-party/kenney-nl/button_icons/tile_0157.png",
	"res://third-party/kenney-nl/button_icons/tile_0166.png"
]
var touchscreen_paths : PackedStringArray = [
	"res://assets/images/graphics/touch_input/arrow_left_gui.png",
	"res://assets/images/graphics/touch_input/arrow_right_gui.png",
	"res://assets/images/graphics/touch_input/a_button_gui.png",
	"res://assets/images/graphics/touch_input/b_button_gui.png",
	"res://assets/images/graphics/touch_input/view_order_gui.png",
	"res://assets/images/graphics/touch_input/send_sandwhich_gui.png"
]

var input_mode : int = 0
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


func _convert_page_buttons(text_in : String) -> String:
	var result : String = text_in
	
	for idx in button_replace_codes.size():
		if text_in.contains(button_replace_codes[idx]):
			var bbimg : String = "[img=16x16]"
			bbimg += control_pad_paths[idx]
			bbimg += "[/img]"
			result.replace(button_replace_codes[idx], bbimg)
	
	return result


func _load_page(num : int):
	current_page = num
	title.text = titles[current_page]
	page.text = _convert_page_buttons(pages[current_page])
	guide.play(guide_names[current_page])
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
