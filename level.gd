extends Node2D

const TIME_LIMIT := 100
const PlayerScene := preload("res://player.tscn")

var player_start_position := Vector2(0, 0)
var player_start_rotation := 0.0

@onready var player: Player = $Player
@onready var camera: Camera = $Camera2D
@onready var status_bar: StatusBar = $CanvasLayer/StatusBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("exploded", _on_player_exploded)
	player_start_position = player.global_position
	player_start_rotation = player.rotation

	Globals.time = TIME_LIMIT

	if has_node("Keys"):
		for key in $Keys.get_children():
			key.connect("picked", _on_key_picked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	status_bar.update()

	if Globals.time > 1:
		Globals.time -= delta
	else:
		Globals.time = 0

		if is_instance_valid(player):
			player.hit()


func _on_player_exploded() -> void:
	await get_tree().create_timer(1).timeout

	Globals.lives -= 1

	if Globals.lives > 0:
		_instantiate_player()

		if Globals.time <= 0:
			Globals.time = TIME_LIMIT
	else:
		Globals.change_scene("game_over")


func _instantiate_player() -> void:
	var new_player: Player = PlayerScene.instantiate()
	new_player.connect("exploded", _on_player_exploded)
	new_player.global_position = player_start_position
	new_player.rotation = player_start_rotation
	call_deferred("add_child", new_player)
	camera.target_node = new_player
	player = new_player


func _on_finish_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Globals.next_level()


func _on_key_picked(key: Key) -> void:
	_open_door(key)


func _open_door(key: Key) -> void:
	if !has_node("Doors"):
		return

	for door in $Doors.get_children():
		if door.type == key.type:
			door.queue_free()
			break
