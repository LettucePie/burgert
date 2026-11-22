extends Control
@export var active : bool = true
@onready var label : Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !active:
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var static_mem_bytes : float = Performance.get_monitor(Performance.MEMORY_STATIC)
	var vram_bytes : float = Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)
	var item_count : int = Performance.get_monitor(Performance.OBJECT_COUNT)
	var res_count : int = Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)
	var renobj_count : int = Performance.get_monitor(Performance.RENDER_TOTAL_OBJECTS_IN_FRAME)
	var draw_count : int = Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)
	label.text = "mem: " + str(static_mem_bytes) + "\nvram: " + str(vram_bytes) + "\nobj: " + str(item_count) + "\nres: " + str(res_count) + "\nrend: " + str(renobj_count) + "\ndraws: " + str(draw_count)
