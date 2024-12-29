class_name Level

extends Node2D

const PlayerScene := preload("res://player.tscn")

var player_start_position := Vector2(0, 0)

@onready var player := $Player as Player
@onready var camera := $Camera2D as Camera
@onready var status_bar := $CanvasLayer/StatusBar as StatusBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("exploded", _on_player_exploded)
	player_start_position = player.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_exploded() -> void:
	await get_tree().create_timer(1).timeout

	Globals.lives -= 1
	status_bar.update()

	if Globals.lives > 0:
		instantiate_player()
	else:
		Globals.change_scene("game_over")


func instantiate_player() -> void:
	var new_player := PlayerScene.instantiate() as Player
	new_player.connect("exploded", _on_player_exploded)
	new_player.global_position = player_start_position
	call_deferred("add_child", new_player)
	camera.target_node = new_player


func _on_finish_body_entered(_body: Node2D) -> void:
	Globals.next_level()
