extends Node
class_name MultiLang

## Supported Languages by 639-2 Codes
## Ref https://en.wikipedia.org/wiki/List_of_ISO_639-2_codes
@export var supported_languages : PackedStringArray = [
	"eng",
	"example",
]
## Supported Languages in legible form.
@export var supported_languages_named : PackedStringArray = [
	"English",
	"English-EX"
]
## The Language Masterfile that hosts all the text / image paths per marked nodepath
@export_file("*.json") var lang_master
## Builds a reference template to every game element marked with the group tags
## lang_text , lang_text_array , lang_image , lang_image_array
@export var build_template : bool = false
## The Directory for where to put the Reference Template
@export_dir var save_target_dir
## The Name of the Reference Template File.
@export var save_target_name : String = "lang_master_template"

@onready var lang_image_nodes : Array = get_tree().get_nodes_in_group("lang_image")
@onready var lang_image_hosts : Array = get_tree().get_nodes_in_group("lang_image_array")
@onready var lang_text_nodes : Array = get_tree().get_nodes_in_group("lang_text")
@onready var lang_text_hosts : Array = get_tree().get_nodes_in_group("lang_text_array")

@export var starting_lang : String = "eng"
var current_lang : String = "eng"

func _ready():
	if build_template:
		_build_template()
	load_lang(starting_lang)


func _process(delta : float):
	pass


func introduce_language_selector(selector : LanguageSelector):
	print("Connecting Language Selector: ", selector, " to Multi-Lang")
	selector.populate_list(supported_languages_named, _on_language_selector_lang_selected)


func _on_language_selector_lang_selected(idx : int):
	print("Multi-Lang recieved request to switch language to ", supported_languages_named[idx])
	load_lang(supported_languages[idx])


## The ugliest brick of code you will ever see
func load_lang(target : String):
	if supported_languages.has(target) and current_lang != target:
		print("Loading target language: ", target)
		var lang_file = FileAccess.open(lang_master, FileAccess.READ)
		print("Language File Opened")
		var text = lang_file.get_as_text()
		var json = JSON.new()
		var parse = json.parse(text)
		if not parse == OK:
			print("JSON Parse Error: ", json.get_error_message(), 
				" at line ", json.get_error_line())
		var data = json.get_data()
		if data.has("languages"):
			print("Language File at: ", lang_master, " is valid")
			#print("has eng: ", data.has("eng"))
			var target_block = data["languages"][0]
			var valid = false
			for i in data["languages"].size():
				print("INDEX: ", i)
				if data["languages"][i].has(target):
					target_block = data["languages"][i][target]
					valid = true
			if valid:
				print("Language File has found target lang: ", target)
				for n in target_block:
					print("\n", n["path"])
					print(n["data1"]["type"])
					print(n["data1"]["data2"])
					var path = n["path"]
					if get_window().get_child(0) is GameContainer:
						path = path.lstrip("/root")
						path = "/root/GameContainer/GameWorldPort/" + path
						print("Containered_Path: ", path)
					var node : Node = get_node(NodePath(path))
					if n["data1"]["type"] == "text":
						node.text = n["data1"]["data2"]
					if n["data1"]["type"] == "image":
						node.texture = load(n["data1"]["data2"])
					if n["data1"]["type"] == "image_host":
						for ix in n["data1"]["data2"].size():
							var setter = n["data1"]["setter"][ix][0]
							print(setter)
							if node.has_method(setter):
								print("ImageHost: ", node, " Has Method: ", setter)
								var send = []
								for res in n["data1"]["data2"][ix]:
									print(ix, " | ", res)
									send.append(load(res))
								node.call(setter, send)
					if n["data1"]["type"] == "text_host":
						for ix in n["data1"]["data2"].size():
							var setter = n["data1"]["setter"][ix][0]
							print(setter)
							if node.has_method(setter):
								print("TextHost: ", node, " Has Method: ", setter)
								var send = n["data1"]["data2"][ix]
								node.call(setter, send)
				current_lang = target
			else:
				print("Sorry, Failed to find target: ", target, " in ", lang_master)
		else:
			print("JSON Error, failed to find Data-Root \"languages\"")


func _build_template():
	print("BUILDING Multi-Lang Template")
	var lang_code = {
		"eng" = []
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
		lang_code["eng"].append(data0)
	
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
		lang_code["eng"].append(data0)
	
	for image_host in lang_image_hosts:
		var data0 = {
			"path" = "",
			"data1" = [],
		}
		data0["path"] = image_host.get_path()
		data0["data1"] = {
			"data2" = [
				["OVERRIDE_MULTIPLE_TEXTURE_PATHS"],
				["OVERRIDE_MULTIPLE_TEXTURE_PATHS"],
				["..."],
			],
			"type" = "image_host",
			"setter" = [
				["OVERRIDE_SETTER_METHOD"],
				["OVERRIDE_SETTER_METHOD"],
				["..."],
			]
		}
		lang_code["eng"].append(data0)
	
	for text_host in lang_text_hosts:
		var data0 = {
			"path" = "",
			"data1" = []
		}
		data0["path"] = text_host.get_path()
		data0["data1"] ={
			"data2" = [
				["OVERRIDE_MULTIPLE_STRINGS"],
				["OVERRIDE_MULTIPLE_STRINGS"],
				["..."],
			],
			"type" = "text_host",
			"setter" = [
				["OVERRIDE_SETTER_METHOD"],
				["OVERRIDE_SETTER_METHOD"],
				["..."],
			]
		}
		lang_code["eng"].append(data0)
	
	var output = {
		"languages" = []
	}
	output["languages"].append(lang_code)
	
	print(output)
	## Save
	print("Writing to File... ", save_target_dir, "/", save_target_name)
	var file = FileAccess.open(save_target_dir + "/" + save_target_name + ".json", FileAccess.WRITE)
	print(FileAccess.get_open_error())
	var json_string = JSON.stringify(output, "\t")
	file.store_line(json_string)
	print("Build Template Written")
