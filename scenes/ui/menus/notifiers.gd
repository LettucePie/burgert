extends Control
class_name Notifier

signal notifier_started()
signal notifier_finished()

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var picture_rect : TextureRect = $Panel/picture_panel/picture
@onready var name_label : Label = $Panel/name_panel/name_label
@onready var content : Label = $Panel/notification_content
@export var profile_pictures : Array[Texture2D] = []
var finished : bool = false
var closing : bool = false

var notification_table : Array = [
	[0, "Gramps", "Content"]
]


func display_notification(idx : int) -> void:
	self.show()
	var table = notification_table[idx]
	picture_rect.texture = profile_pictures[table[0]]
	name_label.text = table[1]
	content.text = table[2]
	finished = false
	closing = false
	anim.play("notification_start")
	emit_signal("notifier_started")


func _process(delta: float) -> void:
	if finished and !closing:
		if Input.is_action_just_released("cancel") \
		or Input.is_action_just_released("confirm"):
			_close_notification()


func _close_notification() -> void:
	closing = true
	anim.play("notification_end")
	emit_signal("notifier_finished")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed and finished and !closing:
			_close_notification()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "notification_start":
		finished = true
	if anim_name == "notification_end":
		closing = false
		self.hide()
