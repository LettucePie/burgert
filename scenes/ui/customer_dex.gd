extends Control
class_name CustomerDex

@export var customer_names : PackedStringArray
@export var customer_images : Array[Texture2D]
@export var customer_descriptions : PackedStringArray



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pagebutton_pressed(dir: int) -> void:
	print("CustomerDex PageButton: ", dir)
