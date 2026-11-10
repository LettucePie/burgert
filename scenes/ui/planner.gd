extends TextureRect
class_name Planner

## Info display
@onready var stencil : TextureRect = $Control/stencil
@onready var stencil_glow : TextureRect = $Control/stencil_glow
@export var stencil_textures : Array[Texture2D] = []
@onready var 
## FX
@onready var stencil_fx : TextureRect = $Control/stencil/stencil_fx
@export var stencil_fx_textures : Array[Texture2D] = []
@onready var stencil_fx_atlas : AtlasTexture = stencil_fx.texture
@onready var stencil_noise : TextureRect = $Control/stencil_noise
@onready var stencil_noise_atlas : AtlasTexture = stencil_noise.texture
var y_pos : float = 0.0
var y_pos_noise : float = 0.0
var flicker_reset : float = 300.0


func assign_stencil_textures(idx : int) -> void:
	stencil.visible = idx >= 0
	stencil_glow.visible = idx >= 0
	stencil.texture = stencil_textures[0]
	stencil_glow.texture = stencil_textures[0]


func _ready() -> void:
	assign_stencil_textures(-1)


func _physics_process(delta: float) -> void:
	y_pos += 0.9
	stencil_fx_atlas.region = Rect2(0, y_pos, 4, 4)
	if y_pos > flicker_reset:
		y_pos = 0
		flicker_reset = randf_range(100.0, 500.0)
		stencil_fx_atlas.atlas = stencil_fx_textures.pick_random()
	y_pos_noise += 0.6
	if y_pos_noise > 200.0:
		y_pos_noise = 0.0
	stencil_noise_atlas.region = Rect2(0, y_pos_noise, 128, 70)
