extends RigidBody2D

enum TurningState { NONE, LEFT, RIGHT }
enum EnemyState { FREE_FLIGHT, TRACKING }

const MOVE_SPEED := 80.0
const ROTATION_SPEED := 20.0
const RAY_CAST_LENGTH := 300.0
const TIME_LOST_SIGHT := 10.0

const BulletScene := preload("res://bullet.tscn")
const ExplosionScene := preload("res://explosion.tscn")

var turning_state: TurningState = TurningState.NONE
var stationary_time := 0.0
var previous_position := Vector2()
var previous_rotation := 0.0
var current_state: EnemyState = EnemyState.FREE_FLIGHT
var time_since_player_seen := 0.0

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_center: RayCast2D = $RayCastCenter
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var player: Player = get_node("/root/Level/Player")
@onready var shoot_timer: Timer = $ShootTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass  # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	var left_colliding := ray_cast_left.is_colliding()
	var center_colliding := ray_cast_center.is_colliding()
	var right_colliding := ray_cast_right.is_colliding()

	var left_distance := ray_cast_left.get_collision_point().distance_to(
		ray_cast_left.global_position
	)
	var center_distance := ray_cast_center.get_collision_point().distance_to(
		ray_cast_center.global_position
	)
	var right_distance := ray_cast_right.get_collision_point().distance_to(
		ray_cast_right.global_position
	)

	if not center_colliding:
		turning_state = TurningState.NONE
	if left_colliding and not right_colliding:
		turning_state = TurningState.RIGHT
	elif right_colliding and not left_colliding:
		turning_state = TurningState.LEFT
	elif left_colliding and right_colliding:
		if turning_state == TurningState.NONE:
			if left_distance < right_distance:
				turning_state = TurningState.RIGHT
			else:
				turning_state = TurningState.LEFT
	elif center_colliding:
		turning_state = TurningState.LEFT if randf() < 0.5 else TurningState.RIGHT
	else:
		turning_state = TurningState.NONE

	var position_diff = global_position.distance_to(previous_position)
	var rotation_diff = abs(rotation - previous_rotation)

	if position_diff < 0.01 and rotation_diff < 0.01:
		stationary_time += delta

		if stationary_time >= 0.5:
			if turning_state == TurningState.LEFT:
				turning_state = TurningState.RIGHT
			elif turning_state == TurningState.RIGHT:
				turning_state = TurningState.LEFT

			stationary_time = 0
	else:
		stationary_time = 0

	previous_position = global_position
	previous_rotation = rotation

	match turning_state:
		TurningState.LEFT:
			apply_torque_impulse(-ROTATION_SPEED * (1 - (left_distance / RAY_CAST_LENGTH)))
		TurningState.RIGHT:
			apply_torque_impulse(ROTATION_SPEED * (1 - (right_distance / RAY_CAST_LENGTH)))

	if center_colliding:
		apply_central_force(
			Vector2(MOVE_SPEED * center_distance / RAY_CAST_LENGTH, 0).rotated(rotation)
		)
		linear_velocity *= 0.95
	else:
		apply_central_force(Vector2(MOVE_SPEED, 0).rotated(rotation))

	if current_state == EnemyState.TRACKING:
		time_since_player_seen += delta

		if time_since_player_seen >= TIME_LOST_SIGHT:
			current_state = EnemyState.FREE_FLIGHT
			$Polygon2D.color = Color(1, 1, 1)
		elif player != null:
			var direction_to_player = (player.global_position - global_position).normalized()
			var angle_to_player = direction_to_player.angle() - rotation
			apply_torque_impulse(angle_to_player * ROTATION_SPEED / 2)


func _explode() -> void:
	var explosion: Explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	queue_free()


func _shoot():
	var bullet: Bullet = BulletScene.instantiate()
	bullet.global_position = Vector2(50, 0).rotated(rotation) + global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)


func _on_view_body_entered(body: Node2D) -> void:
	if body is Player:
		current_state = EnemyState.TRACKING
		$Polygon2D.color = Color(1, 0, 0)
		time_since_player_seen = 0.0
		shoot_timer.start()


func _on_view_body_exited(body: Node2D) -> void:
	if body is Player:
		shoot_timer.stop()


func _on_shoot_timer_timeout() -> void:
	_shoot()


func hit():
	_explode()
