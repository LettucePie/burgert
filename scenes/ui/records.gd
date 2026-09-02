extends Control
class_name Records

signal close_records()

@export var active : bool = false

@onready var total_score : Label = $TextureRect/VBoxContainer/total_score/value
@onready var highest_score : Label = $TextureRect/VBoxContainer/highest_score/value
@onready var spent_score : Label = $TextureRect/VBoxContainer/spent_score/value
@onready var times_played : Label = $TextureRect/VBoxContainer/times_played/value
@onready var burgers_served : Label = $TextureRect/VBoxContainer/burgers_served/value
#var loaded_stats : Play.Stats


func _ready() -> void:
	active = false


func assign_stats(stats : Play.Stats) -> void:
	#loaded_stats = stats
	total_score.text = "$" + str(stats.total_score)
	highest_score.text = "$" + str(stats.highest_score)
	spent_score.text = "$" + str(stats.total_score - stats.spent_score)
	times_played.text = str(stats.times_played)
	var total : int = 0
	for cs in stats.customer_stats:
		total += cs.orders_served
	burgers_served.text = str(total)


func _process(delta: float) -> void:
	if active:
		if Input.is_action_just_released("cancel") \
		or Input.is_action_just_released("confirm"):
			print("Close Records")
			emit_signal("close_records")


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if !event.pressed:
			emit_signal("close_records")
