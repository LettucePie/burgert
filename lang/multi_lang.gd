extends Node
class_name MultiLang

## Ref https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes

@export var build_template : bool = false
@export var supported_languages : PackedStringArray = [
	"eng",
	"example",
]
@export_file("*.json") var lang_master
@export_dir var save_target_dir
@export var save_target_name : String = "lang_master"


@onready var lang_image_nodes : Array = get_tree().get_nodes_in_group("lang_image")
@onready var lang_image_hosts : Array = get_tree().get_nodes_in_group("lang_image_array")
@onready var lang_text_nodes : Array = get_tree().get_nodes_in_group("lang_text")

func _ready():
	if build_template:
		_build_template()


func _build_template():
	print("BUILDING Multi-Lang Template")
	var lang_code = {
		"639-2" = "eng",
		"data0" = [],
	}
	
	for text_node in lang_text_nodes:
		var data0 = {
			"path" = "",
			"data1" = [],
		}
		data0["path"] = text_node.get_path()
		data0["data1"] = {
			"data2" = text_node.text,
			"type" = "text",
		}
		lang_code["data0"].append(data0)
	
	for image_node in lang_image_nodes:
		var data0 = {
			"path" = "",
			"data1" = [],
		}
		data0["path"] = image_node.get_path()
		data0["data1"] = {
			"data2" = "OVERRIDE_TEXTURE_PATH",
			"type" = "image",
		}
		lang_code["data0"].append(data0)
		
	print(lang_code)
	## Save
	print("Writing to File... ", save_target_dir, "/", save_target_name)
	var file = FileAccess.open(save_target_dir + "/" + save_target_name + ".json", FileAccess.WRITE)
	print(FileAccess.get_open_error())
	var json_string = JSON.stringify(lang_code, "\t")
	file.store_line(json_string)
	print("Build Template Written")
