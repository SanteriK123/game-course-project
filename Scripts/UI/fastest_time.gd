extends Label

func _ready() -> void:
	var best_time = load_from_file()
	text = "Best time: " + best_time

func load_from_file() -> String:
	if not FileAccess.file_exists("user://best_time.dat"):
		return "0"
	var file = FileAccess.open("user://best_time.dat", FileAccess.READ)
	var content = file.get_as_text()
	return content
