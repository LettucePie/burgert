extends Control
class_name MainSandwhich
signal menu_selection(selection)

@onready var stack : Array = $Sandwhich.get_children()
var current_stack : int = 0
var stack_max : int = 8
@export var active : bool = true
@export var label_container : PanelContainer
@export var label : Label
var label_tween : Tween = null
var stack_labels_internal : PackedStringArray = [
	"Quit",
	"Credits",
	"Jukebox",
	"Help",
	"Options",
	"Records",
	"Customer-Dex",
	"Play",
	""
]
var stack_labels_translated : PackedStringArray = [
	"Quit",
	"Credits",
	"Jukebox",
	"Help",
	"Options",
	"Records",
	"Customer-Dex",
	"Play",
	""
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_stack = stack.size() - 1
	_fill_label(current_stack)
	go_to_layer("")


func _tween_layer_in(obj : Sprite2D):
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(obj, "position", Vector2.ZERO, 0.2)
	var rot_target = randf_range(PI * -0.05, PI * 0.05)
	tween.set_parallel()
	tween.tween_property(obj, "rotation", rot_target, 0.3)


func _tween_layer_out(obj : Sprite2D):
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(obj, "position", Vector2(0, 300), 0.2)
	var rot_target = PI
	if randi_range(0, 1) > 0:
		rot_target *= -1
	tween.set_parallel()
	tween.tween_property(obj, "rotation", rot_target, 0.3)


func _adjust_stack(arg : int):
	print("Adjusting Stack from: ", current_stack, " by: ", arg)
	var layer : Sprite2D = stack[current_stack]
	if arg < 0 and current_stack != 0:
		_tween_layer_out(layer)
		current_stack += arg
	elif arg > 0 and current_stack != stack_max:
		current_stack += arg
		layer = stack[current_stack]
		_tween_layer_in(layer)
	_fill_label(current_stack)


func _fill_label(idx : int) -> void:
	label.text = stack_labels_translated[idx]
	if label.text != "":
		label_container.show()
	else:
		label_container.hide()
	label.visible_ratio = 0.0
	if label_tween != null:
		label_tween.kill()
	label_tween = create_tween()
	label_tween.tween_property(label, "visible_ratio", 1.0, label.text.length() * 0.02)


func _process(delta: float) -> void:
	if active:
		if Input.is_action_just_pressed("down") \
		or Input.is_action_just_pressed("left"):
			_adjust_stack(-1)
		elif Input.is_action_just_pressed("up") \
		or Input.is_action_just_pressed("right"):
			_adjust_stack(1)
		if Input.is_action_just_pressed("confirm"):
			emit_signal("menu_selection", stack_labels_internal[current_stack])


func go_to_layer(layer_name : String) -> void:
	var target_idx = stack_labels_internal.find(layer_name)
	var difference : int = abs(current_stack - target_idx)
	var direction : int = -1
	print("Going to Layer: ", layer_name, " at idx: ", target_idx)
	if target_idx > current_stack:
		direction = 1
	for i in difference:
		_adjust_stack(direction)
