extends Node2D

const PlayerScene := preload("res://entities/player.tscn")

@export var time_limit := 100.0
@export var history_duration := 3.0

var global_time := 0.0
var position_history := []
var rotation_history := []
var player_start_position := Vector2(0, 0)
var player_start_rotation := 0.0

@onready var player: Player = $Player
@onready var camera: Camera = $Camera2D
@onready var status_bar: StatusBar = $CanvasLayer/StatusBar
@onready var result: Result = $CanvasLayer/Result
@onready var finish: Finish = $Finish
@onready var time := time_limit


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("exploded", _on_player_exploded)
	player_start_position = player.global_position
	player_start_rotation = player.rotation

	if has_node("Keys"):
		for key in $Keys.get_children():
			key.connect("picked", _on_key_picked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_time += delta

	if player != null:
		position_history.append({"time": global_time, "position": player.global_position})
		rotation_history.append({"time": global_time, "rotation": player.global_rotation})

	while (
		position_history.size() > 0
		and position_history[0]["time"] < global_time - history_duration - 0.1
	):
		position_history.remove_at(0)

	while (
		rotation_history.size() > 0
		and rotation_history[0]["time"] < global_time - history_duration - 0.1
	):
		rotation_history.remove_at(0)

	status_bar.update(Globals.lives, time)

	if time > 1:
		time -= delta
	else:
		if player != null:
			player.hit()
			await get_tree().create_timer(1).timeout
			result.time_out()


func _on_player_exploded() -> void:
	await get_tree().create_timer(1).timeout

	Globals.lives -= 1

	if Globals.lives > 0:
		_instantiate_player()
	else:
		result.level_failed()


func _instantiate_player() -> void:
	var new_player: Player = PlayerScene.instantiate()
	new_player.connect("exploded", _on_player_exploded)

	var target_time := global_time - history_duration

	var new_position := player_start_position
	for i in range(position_history.size() - 1, -1, -1):
		if position_history[i]["time"] <= target_time:
			new_position = position_history[i]["position"]
			break

	var new_rotation := player_start_rotation
	for i in range(rotation_history.size() - 1, -1, -1):
		if rotation_history[i]["time"] <= target_time:
			new_rotation = rotation_history[i]["rotation"]
			break

	new_player.global_position = new_position
	new_player.global_rotation = new_rotation

	call_deferred("add_child", new_player)
	camera.target_node = new_player
	player = new_player


func _level_completion() -> void:
	if Globals.level >= Globals.LEVEL_COUNT:
		Globals.change_scene("screens/victory")
	else:
		result.level_completed()

	if Globals.level > Globals.reached_level:
		Globals.reached_level = Globals.level
		Globals.save()


func _on_finish_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var tween = create_tween().set_parallel(true)

		(
			tween
			. tween_property(player, "global_position", finish.global_position, 0.5)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_IN_OUT)
		)
		(
			tween
			. tween_property(player, "rotation", player.rotation + deg_to_rad(360), 0.5)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_IN_OUT)
		)
		(
			tween
			. tween_property(player, "scale", player.scale * 0.0, 0.5)
			. set_trans(Tween.TRANS_SINE)
			. set_ease(Tween.EASE_IN_OUT)
		)

		tween.connect("finished", _level_completion)


func _on_key_picked(key: Key) -> void:
	_open_door(key)


func _open_door(key: Key) -> void:
	if !has_node("Doors"):
		return

	for door in $Doors.get_children():
		if door.type == key.type:
			door.queue_free()
			break
