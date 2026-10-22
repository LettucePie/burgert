extends Control
class_name RegularPrinter

signal printer_finished

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var profile : TextureRect = $printer/polaroid/profile
var customer_dex : CustomerDex = null
var printer_queue : PackedStringArray = []
var idx : int = 0

func _assign_customer_dex(cd : CustomerDex) -> void:
	customer_dex = cd


func begin_print_sequence() -> void:
	idx = 0
	anim.play("printer_enter")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "printer_enter":
		profile.texture = customer_dex.customer_images[customer_dex.customer_names_internal.find(printer_queue[idx])]
		anim.play("printout")
	if anim_name == "printout":
		idx += 1
		if idx <= printer_queue.size() - 1:
			profile.texture = customer_dex.customer_images[customer_dex.customer_names_internal.find(printer_queue[idx])]
			anim.play("printout")
		else:
			anim.play("printer_exit")
			emit_signal("printer_finished")
