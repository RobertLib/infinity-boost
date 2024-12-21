extends Node2D

const BulletScene := preload("res://weapons/bullet.tscn")

@onready var timer: Timer = $Timer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = randf_range(0.5, 2.0)
	timer.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	var offset = Vector2(24, 0)
	bullet.global_transform = global_transform.translated(offset.rotated(global_rotation))
	get_node("/root/Level").add_child(bullet)

	timer.wait_time = randf_range(1.0, 3.0)
	timer.start()
