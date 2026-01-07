extends Node2D
class_name Accessory

var tile_size : Vector2 = Vector2(48, 48)
var hair_count : int = 20
var beard_count : int = 10
var glasses_count : int = 10


func shuffle() -> void:
	randomize()
	$hair.hide()
	$beard.hide()
	$glasses.hide()
	if randi_range(0, 10) >= 3:
		$hair.show()
		$hair.texture.region = Rect2(0, randi_range(0, hair_count) * 48, 48, 48)
	if randi_range(0, 10) >= 6:
		$beard.show()
		$beard.texture.region = Rect2(0, randi_range(0, beard_count) * 48, 48, 48)
	if randi_range(0, 10) >= 4:
		$glasses.show()
		$glasses.texture.region = Rect2(0, randi_range(0, glasses_count) * 48, 48, 48)
