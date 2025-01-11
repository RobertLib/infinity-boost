class_name Player

extends RigidBody2D

signal exploded

const UPWARD_FORCE := Vector2(0, -120)
const ROTATION_SPEED := 60.0

const ExplosionScene := preload("res://explosion.tscn")
const BulletScene := preload("res://bullet.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(_delta: float) -> void:
	if Input.is_action_pressed("ui_left"):
		apply_torque_impulse(-ROTATION_SPEED)
		linear_velocity *= 0.98
	elif Input.is_action_pressed("ui_right"):
		apply_torque_impulse(ROTATION_SPEED)
		linear_velocity *= 0.98


func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	var rotated_force := UPWARD_FORCE.rotated(rotation)
	apply_central_force(rotated_force)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacle"):
		_explode()


func _explode() -> void:
	var explosion: Explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	exploded.emit()
	queue_free()


func _shoot():
	var bullet: Bullet = BulletScene.instantiate()
	bullet.global_position = Vector2(0, -30).rotated(rotation) + global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_select"):
		_shoot()


func hit():
	_explode()
