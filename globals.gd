extends Node

const STARTING_LIVES := 3
const LEVEL_COUNT := 2

var lives := STARTING_LIVES
var level := 1


func change_scene(path: String) -> void:
	get_tree().change_scene_to_file("res://" + path + ".tscn")


func change_level(number: int) -> void:
	if number > 0 and number <= LEVEL_COUNT:
		level = number
		call_deferred("change_scene", "level_" + str(level))

	lives = STARTING_LIVES


func next_level() -> void:
	level += 1

	if level > LEVEL_COUNT:
		call_deferred("change_scene", "victory")
	else:
		call_deferred("change_scene", "level_" + str(level))
