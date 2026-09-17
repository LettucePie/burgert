extends Sprite2D
class_name Rune

@export var highlight : Sprite2D
@export var auras : Array[Sprite2D] = []
var highlighted : bool = false
var ticks : PackedInt32Array = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for a in auras:
		ticks.append(randi_range(12, 50))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if visible:
		for i in ticks.size():
			ticks[i] -= 1
			if ticks[i] < 0:
				randomize()
				ticks[i] = randi_range(22, 55)
				auras[i].position = Vector2(
					randf_range(-3, 3),
					randf_range(-3, 3)
				)
	highlight.visible = highlighted
