extends Node2D

const PlayerScene := preload("res://player.tscn")

var player_start_position := Vector2(0, 0)

@onready var player: Player = $Player
@onready var camera: Camera = $Camera2D
@onready var status_bar: StatusBar = $CanvasLayer/StatusBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("exploded", _on_player_exploded)
	player_start_position = player.global_position

	if has_node("Keys"):
		for key in $Keys.get_children():
			key.connect("picked", _on_key_picked)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_exploded() -> void:
	await get_tree().create_timer(1).timeout

	Globals.lives -= 1
	status_bar.update()

	if Globals.lives > 0:
		_instantiate_player()
	else:
		Globals.change_scene("game_over")


func _instantiate_player() -> void:
	var new_player: Player = PlayerScene.instantiate()
	new_player.connect("exploded", _on_player_exploded)
	new_player.global_position = player_start_position
	call_deferred("add_child", new_player)
	camera.target_node = new_player


func _on_finish_body_entered(_body: Node2D) -> void:
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
