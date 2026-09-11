extends Control
class_name Shop

signal close_shop()

var connected : bool = false
var connect_stage : int = 0

@onready var main : Control = $phone/main
@onready var finished : Button = $phone/main/vcont1/finished
@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var connection_label : Label = $phone/connection/label
@export var connection_messages : PackedStringArray = [
	"connecting",
	"connected!",
	"welcome to\n\nGLORBAZON"
]

#func _ready() -> void:
	#open_shop()

func open_shop():
	connected = false
	connect_stage = 0
	anim.play("connect")
	await get_tree().create_timer(randf_range(1.8, 3.2)).timeout
	anim.play("connected")
	#main.show()
	#finished.grab_focus()


func update_connection_stage():
	connect_stage += 1
	if connect_stage <= 2:
		connection_label.text = connection_messages[connect_stage]
	else:
		finished.grab_focus()


func _on_finished_pressed() -> void:
	emit_signal("close_shop")


func _tween_center() -> void:
	self.position = Vector2(0, randf_range(2, 4))
	self.rotation = randf_range(-0.03, 0.03)
	var tween : Tween = create_tween().set_trans(Tween.TRANS_SINE)
	tween.tween_property(self, "position", Vector2.ZERO, 0.2)
	tween.set_parallel()
	tween.tween_property(self, "rotation", 0.0, 0.1)
	


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up") \
	or Input.is_action_just_pressed("down") \
	or Input.is_action_just_pressed("confirm") \
	or Input.is_action_just_pressed("cancel"):
		_tween_center()
