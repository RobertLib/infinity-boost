extends Node

const STARTING_LIVES := 3
const LEVEL_COUNT := 3

var lives := STARTING_LIVES
var level := 1
var reached_level := 0


func change_scene(path: String) -> void:
	get_tree().call_deferred("change_scene_to_file", "res://" + path + ".tscn")


func change_level(number: int) -> void:
	if number > 0 and number <= LEVEL_COUNT:
		level = number
		change_scene("levels/level_" + str(level))

	lives = STARTING_LIVES


func restart_level() -> void:
	change_level(level)


func next_level() -> void:
	if level < LEVEL_COUNT:
		change_level(level + 1)


func save() -> void:
	var save_data := {"reached_level": reached_level}
	var save_file := FileAccess.open("user://savegame.save", FileAccess.WRITE)

	save_file.store_var(save_data)
	save_file.close()


func load() -> void:
	if FileAccess.file_exists("user://savegame.save"):
		var save_file := FileAccess.open("user://savegame.save", FileAccess.READ)
		var save_data = save_file.get_var()

		reached_level = save_data["reached_level"]
		save_file.close()


func clear_save() -> void:
	var dir := DirAccess.open("user://")

	if dir and dir.file_exists("savegame.save"):
		dir.remove("savegame.save")
