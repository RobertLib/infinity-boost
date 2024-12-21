extends RigidBody2D

enum TurningState { NONE, LEFT, RIGHT }
enum EnemyState { FREE_FLIGHT, TRACKING }

const MOVE_SPEED := 80.0
const ROTATION_SPEED := 20.0
const TRACKING_ROTATION_SPEED := 40.0
const RAY_CAST_LENGTH := 300.0
const TIME_LOST_SIGHT := 3.0
const OBSTACLE_AVOIDANCE_PRIORITY := 0.7
const OBSTACLE_LAYER := 0b00000010  # Layer 2 for obstacles

const BulletScene := preload("res://weapons/bullet.tscn")
const ExplosionScene := preload("res://effects/explosion.tscn")

var turning_state: TurningState = TurningState.NONE
var stationary_time := 0.0
var previous_position := Vector2()
var previous_rotation := 0.0
var current_state: EnemyState = EnemyState.FREE_FLIGHT
var time_since_player_seen := 0.0
var player_ref: Player = null
var last_seen_player_pos := Vector2.ZERO
var last_seen_player_vel := Vector2.ZERO

@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var ray_cast_center: RayCast2D = $RayCastCenter
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var shoot_timer: Timer = $ShootTimer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not shoot_timer.is_connected("timeout", _on_shoot_timer_timeout):
		shoot_timer.connect("timeout", _on_shoot_timer_timeout)
	shoot_timer.wait_time = randf_range(0.5, 1.5)
	shoot_timer.one_shot = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	if player_ref == null or not is_instance_valid(player_ref):
		player_ref = get_node_or_null("/root/Level/Player")

	var obstacle_torque := _handle_obstacle_avoidance(delta)

	var tracking_torque := 0.0
	if current_state == EnemyState.TRACKING:
		tracking_torque = _handle_player_tracking(delta)

	var final_torque := (
		obstacle_torque * OBSTACLE_AVOIDANCE_PRIORITY
		+ tracking_torque * (1.0 - OBSTACLE_AVOIDANCE_PRIORITY)
	)
	apply_torque_impulse(final_torque)

	_apply_movement()

	# Update variables to detect stuck
	previous_position = global_position
	previous_rotation = rotation


func _handle_obstacle_avoidance(delta: float) -> float:
	var left_colliding := ray_cast_left.is_colliding()
	var center_colliding := ray_cast_center.is_colliding()
	var right_colliding := ray_cast_right.is_colliding()

	var left_distance := RAY_CAST_LENGTH
	var right_distance := RAY_CAST_LENGTH

	if left_colliding:
		left_distance = ray_cast_left.global_position.distance_to(
			ray_cast_left.get_collision_point()
		)
	if right_colliding:
		right_distance = ray_cast_right.global_position.distance_to(
			ray_cast_right.get_collision_point()
		)

	# Determine turning state based on raycasts
	if not center_colliding and not left_colliding and not right_colliding:
		turning_state = TurningState.NONE
	elif left_colliding and not right_colliding:
		turning_state = TurningState.RIGHT
	elif right_colliding and not left_colliding:
		turning_state = TurningState.LEFT
	elif left_colliding and right_colliding:
		if turning_state == TurningState.NONE:
			turning_state = (
				TurningState.RIGHT if left_distance < right_distance else TurningState.LEFT
			)
	elif center_colliding:
		turning_state = TurningState.LEFT if randf() < 0.5 else TurningState.RIGHT

	# Check if we're stuck
	var position_diff := global_position.distance_to(previous_position)
	var rotation_diff: float = abs(rotation - previous_rotation)

	if position_diff < 0.01 and rotation_diff < 0.01:
		stationary_time += delta
		if stationary_time >= 0.5:
			# Switch direction if stuck
			turning_state = (
				TurningState.RIGHT if turning_state == TurningState.LEFT else TurningState.LEFT
			)
			stationary_time = 0
			# Add a small random impulse to help get unstuck
			apply_central_impulse(Vector2(randf_range(30.0, 50.0), 0).rotated(randf_range(0, TAU)))
	else:
		# Reset stationary time if moving
		stationary_time = 0

	# Calculate obstacle avoidance torque
	var torque := 0.0
	match turning_state:
		TurningState.LEFT:
			torque = -ROTATION_SPEED * (1.0 - (left_distance / RAY_CAST_LENGTH))
		TurningState.RIGHT:
			torque = ROTATION_SPEED * (1.0 - (right_distance / RAY_CAST_LENGTH))

	return torque


func _handle_player_tracking(delta: float) -> float:
	time_since_player_seen += delta

	if time_since_player_seen >= TIME_LOST_SIGHT:
		current_state = EnemyState.FREE_FLIGHT
		shoot_timer.stop()
		return 0.0

	if player_ref == null or not is_instance_valid(player_ref):
		time_since_player_seen += delta * 2.0  # Count faster if player not found
		return 0.0

	var torque := 0.0

	var direction_to_player := player_ref.global_position - global_position

	direction_to_player = direction_to_player.normalized()

	var forward_direction := Vector2(1, 0).rotated(rotation)

	var angle_diff := forward_direction.angle_to(direction_to_player)

	var speed_factor := 1.0
	if abs(angle_diff) > PI / 2:
		# Player is more behind us, turn faster
		speed_factor = 1.5
	elif abs(angle_diff) < PI / 6:
		# Player is mostly in front, fine tune
		speed_factor = 0.8

	torque = angle_diff * TRACKING_ROTATION_SPEED * speed_factor

	# Enhanced behavior for when player is temporarily out of sight
	if time_since_player_seen > 0.5 and time_since_player_seen < TIME_LOST_SIGHT:
		# Enemy has lost direct sight but is actively searching

		# Increase rotation speed when searching
		torque *= 1.2

		# Add search pattern for more natural hunting behavior
		if time_since_player_seen > 1.5:
			# Use search patterns in advanced search phase
			var search_pattern := sin(time_since_player_seen * 2.0) * PI / 4
			torque += search_pattern * TRACKING_ROTATION_SPEED * 0.5

	# Check if we have line of sight to player (for shooting)
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position, player_ref.global_position, OBSTACLE_LAYER
	)
	var result := space_state.intersect_ray(query)

	if result.is_empty():
		# We have clear line of sight, reset timer
		time_since_player_seen = 0.0

		# Store last known player position and velocity
		last_seen_player_pos = player_ref.global_position
		last_seen_player_vel = (
			player_ref.linear_velocity if "linear_velocity" in player_ref else Vector2.ZERO
		)

		# Only shoot if player is somewhat in front of us (within 30 degrees)
		if abs(angle_diff) < PI / 6 and shoot_timer.is_stopped():
			shoot_timer.start()
	else:
		# We don't have line of sight, but try to move to a position where we might
		# Try to find a better position using prediction and flanking

		# Calculate predicted player position based on last known velocity
		var predicted_player_pos := last_seen_player_pos
		if last_seen_player_vel != Vector2.ZERO:
			predicted_player_pos += last_seen_player_vel.normalized() * 100.0

		# Try flanking instead of direct pursuit
		var flanking_vector := (last_seen_player_pos - global_position).rotated(
			PI / 2 * (1 if randf() > 0.5 else -1)
		)
		var flanking_position := global_position + flanking_vector.normalized() * 150.0

		# Check if flanking position has potential line of sight
		var flanking_query := PhysicsRayQueryParameters2D.create(
			flanking_position, predicted_player_pos, OBSTACLE_LAYER
		)
		var flanking_result := space_state.intersect_ray(flanking_query)

		# Determine which direction to move
		if flanking_result.is_empty():
			# Flanking position might give us line of sight, try to move there
			var dir_to_flanking := flanking_position - global_position
			var flanking_angle := forward_direction.angle_to(dir_to_flanking.normalized())
			torque = flanking_angle * TRACKING_ROTATION_SPEED * 1.2  # Move a bit faster when flanking
		else:
			# Continue tracking last known position
			var dir_to_predicted := predicted_player_pos - global_position
			var predicted_angle := forward_direction.angle_to(dir_to_predicted.normalized())
			torque = predicted_angle * TRACKING_ROTATION_SPEED

		if not shoot_timer.is_stopped():
			shoot_timer.stop()

	return torque


func _apply_movement() -> void:
	var center_colliding := ray_cast_center.is_colliding()
	var center_distance := RAY_CAST_LENGTH

	if center_colliding:
		center_distance = ray_cast_center.global_position.distance_to(
			ray_cast_center.get_collision_point()
		)
		# Slow down when approaching obstacles
		var speed_factor := clampf(center_distance / RAY_CAST_LENGTH, 0.1, 1.0)
		apply_central_force(Vector2(MOVE_SPEED * speed_factor, 0).rotated(rotation))
		linear_velocity *= 0.95
	else:
		# Normal movement
		apply_central_force(Vector2(MOVE_SPEED, 0).rotated(rotation))

	# Limit maximum speed to prevent excessive velocity
	if linear_velocity.length() > MOVE_SPEED * 1.5:
		linear_velocity = linear_velocity.normalized() * MOVE_SPEED * 1.5


func _explode() -> void:
	var explosion: Explosion = ExplosionScene.instantiate()
	explosion.global_position = global_position
	get_parent().add_child(explosion)
	queue_free()


func _shoot() -> void:
	var bullet: Bullet = BulletScene.instantiate()
	bullet.global_position = Vector2(50, 0).rotated(rotation) + global_position
	bullet.rotation = rotation
	get_parent().add_child(bullet)


func _on_view_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		current_state = EnemyState.TRACKING
		time_since_player_seen = 0.0
		player_ref = body
		shoot_timer.start()


func _on_view_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and body == player_ref:
		# Store last known player position and velocity for tracking purposes
		last_seen_player_pos = player_ref.global_position
		last_seen_player_vel = (
			player_ref.linear_velocity if "linear_velocity" in player_ref else Vector2.ZERO
		)

		# Enter "search mode" - enemy will continue tracking
		# but with slightly increased awareness of losing contact
		time_since_player_seen = 0.2  # Slightly increase to indicate player is no longer directly visible


func _on_shoot_timer_timeout() -> void:
	if (
		current_state == EnemyState.TRACKING
		and player_ref != null
		and is_instance_valid(player_ref)
	):
		_shoot()

		shoot_timer.wait_time = randf_range(0.5, 1.5)
		shoot_timer.start()


func hit() -> void:
	_explode()
