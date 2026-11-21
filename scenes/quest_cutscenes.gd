extends Node2D
class_name QuestCutscenes

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var space : Sprite2D = $space



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	space.region_rect.position.x += delta
