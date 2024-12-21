extends RigidBody2D

const UPWARD_FORCE := Vector2(0, -120)
const ROTATION_SPEED := 60.0


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
