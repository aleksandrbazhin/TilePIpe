extends Resource

class_name GenerationData

var data: Dictionary = {}

func _init(data_path: String):
	data = load_data_from_json(data_path)

func load_data_from_json(data_path: String) -> Dictionary:
	var object_data: Dictionary = {}
	var data_file = File.new()
	if data_file.file_exists(data_path):
		data_file.open(data_path, File.READ)
		var data_json: String = data_file.get_as_text()
		var parse_result: JSONParseResult = JSON.parse(data_json)
		if parse_result.error == OK:
			object_data = parse_result.result
		else:
			print("Data loader error: invalid JSON in: ", data_path)
	else:
		print("Data loader error: invalid data path: ",  data_path)
	return object_data

func get_preset() -> Array:
	return data["data"]

func get_name() -> String:
	return data["name"]

func get_min_input_size() -> Vector2:
	return Vector2(data.min_size.x, data.min_size.y)