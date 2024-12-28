class_name Level

extends Node2D

const PlayerScene := preload("res://player.tscn")

var player_start_position := Vector2(0, 0)

@onready var player := $Player as Player
@onready var camera := $Camera2D as Camera


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.connect("exploded", _on_player_exploded)
	player_start_position = player.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_player_exploded() -> void:
	await get_tree().create_timer(1).timeout
	instantiate_player()


func instantiate_player() -> void:
	var new_player := PlayerScene.instantiate() as Player
	new_player.connect("exploded", _on_player_exploded)
	new_player.global_position = player_start_position
	call_deferred("add_child", new_player)
	camera.target_node = new_player
