extends Node2D

const BulletScene := preload("res://bullet.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	bullet.global_position = global_position + Vector2(24, 0).rotated(rotation)
	get_parent().add_child(bullet)
	bullet.rotation = rotation
