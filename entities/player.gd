class_name Player

extends RigidBody2D

signal exploded

const FORWARD_FORCE := Vector2(120, 0)
const ROTATION_SPEED := 60.0

const BulletScene := preload("res://weapons/bullet.tscn")
const ExplosionScene := preload("res://effects/explosion.tscn")


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
	var rotated_force := FORWARD_FORCE.rotated(rotation)
	apply_central_force(rotated_force)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("obstacle") or body.is_in_group("enemy"):
		_explode()


func _explode() -> void:
	var explosion: Explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	exploded.emit()
	queue_free()


func hit():
	_explode()


func speed_up():
	apply_central_impulse(FORWARD_FORCE.rotated(rotation))
