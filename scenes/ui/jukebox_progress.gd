extends HBoxContainer
class_name JukeboxProgress

@export var tracking_texture : Texture
@export var tick_texture : Texture
var progress : int = 0
var tick_boxes : Array[TextureRect] = []

func _ready() -> void:
	tick_boxes.clear()
	for c in get_children():
		if c.name.contains("tick_"):
			tick_boxes.append(c)
	#print(tick_boxes)
	reset_progress()


func reset_progress() -> void:
	progress = 0
	display_progress()


func set_progress(arg : int) -> void:
	if progress != arg:
		print("JukeBox Set Progress")
		progress = arg
		display_progress()


func display_progress() -> void:
	for tb in tick_boxes:
		tb.texture = tracking_texture
	for i in progress:
		tick_boxes[i].texture = tick_texture
