extends Control
class_name TouchInputs

signal pushed_event(e)

@export var hold_buttons : Array[Button]
@export var release_buttons : Array[Button]

var left_held : bool = false
var right_held : bool = false
var trash_held : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	for hb in hold_buttons:
		hb.pressed.connect(_button_held.bind(hb))
	for rb in release_buttons:
		rb.button_up.connect(_button_released.bind(rb))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if left_held or right_held or trash_held:
		var new_event : InputEventKey = InputEventKey.new()
		var new_action : InputEventAction = InputEventAction.new()
		new_event.pressed = true
		new_action.pressed = true
		if left_held:
			new_event.keycode = KEY_LEFT
			new_action.action = "left"
		if right_held:
			new_event.keycode = KEY_RIGHT
			new_action.action = "right"
		if trash_held:
			new_event.keycode = KEY_X
			new_action.action = "cancel"
		Input.parse_input_event(new_event)
		Input.parse_input_event(new_action)
		#emit_signal("pushed_event", new_event)
		#emit_signal("pushed_event", new_action)


func _button_held(b):
	print("GUIBUTTON Held: ", b)
	left_held = b.name == "LeftArrow"
	right_held = b.name == "RightArrow"
	trash_held = b.name == "TrashSandwhich"


func _button_released(b):
	print("GUIBUTTON Released: ", b)
	var new_event : InputEventKey = InputEventKey.new()
	new_event.pressed = true
	if b.name == "ViewOrder":
		new_event.keycode = KEY_C
	if b.name == "TrashSandwhich":
		new_event.keycode = KEY_X
		trash_held = false
	if b.name == "SendSandwhich":
		new_event.keycode = KEY_UP
	if b.name == "AddIngredient":
		new_event.keycode = KEY_Z
	if b.name == "LeftArrow":
		new_event.keycode = KEY_LEFT
		left_held = false
	if b.name == "RightArrow":
		new_event.keycode = KEY_RIGHT
		right_held = false
	Input.parse_input_event(new_event)
	#emit_signal("pushed_event", new_event)
