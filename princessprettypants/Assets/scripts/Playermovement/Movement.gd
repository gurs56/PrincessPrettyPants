extends CharacterBody2D

# Core movement tuning values.
# Rates are "how quickly to approach target velocity" (higher = snappier).
@export var max_speed: float = 200.0
@export var acceleration_rate: float = 10.0
@export var deceleration_rate: float = 14.0
# Curve power shapes the blend weight:
# 1.0 = linear, >1.0 = gentler start, <1.0 = sharper response.
@export_range(0.2, 4.0, 0.1) var acceleration_curve_power: float = 1.5
@export_range(0.2, 4.0, 0.1) var deceleration_curve_power: float = 1.0


func get_input() -> Vector2:
	var input = Vector2()
	if Input.is_action_pressed("right"):
		input.x += 1
	if Input.is_action_pressed("left"):
		input.x -= 1
	if Input.is_action_pressed("down"):
		input.y += 1
	if Input.is_action_pressed("up"):
		input.y -= 1
	# Keep diagonal speed consistent with horizontal/vertical speed.
	return input


func _curve_weight(linear_weight: float, curve_power: float) -> float:
	# Converts linear blend weight into an eased curve shape.
	return pow(clamp(linear_weight, 0.0, 1.0), curve_power)


func _physics_process(delta: float) -> void:
	var direction = get_input()
	var has_input := direction.length() > 0.0
	# When input exists, we move toward a max-speed vector in that direction.
	# Otherwise, we move toward zero for smooth stopping.
	var target_velocity := direction.normalized() * max_speed if has_input else Vector2.ZERO

	# Use separate tuning for speeding up vs slowing down.
	var rate := acceleration_rate if has_input else deceleration_rate
	var curve_power := acceleration_curve_power if has_input else deceleration_curve_power

	# Exponential smoothing keeps feel consistent across different frame rates.
	var linear_weight := 1.0 - exp(-rate * delta)
	# Apply curve shaping to the smoothing amount for better feel control.
	var curved_weight := _curve_weight(linear_weight, curve_power)
	velocity = velocity.lerp(target_velocity, curved_weight)

	# CharacterBody2D applies collision-aware movement with current velocity.
	move_and_slide()