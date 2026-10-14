extends State

var _ai: AITeammate

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AITeammate
	assert(_ai != null, "Patrol requires an AITeammate actor")
	# Re-apply the current waypoint so the agent drops whatever target the
	# previous state left behind (e.g. the player's position from Follow).
	_ai.set_patrol_index(_ai._patrol_index)

## Called once when the state stops being active.
func exit() -> void:
	_ai.velocity = Vector3.ZERO

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(delta: float) -> void:
	if _ai.nav_agent.is_navigation_finished():
		_ai.set_patrol_index(_ai._patrol_index + 1)
		return

	var dir := _ai.nav_agent.get_next_path_position() - _ai.global_position
	dir.y = 0.0
	if dir.length_squared() < 0.0001:
		return
	dir = dir.normalized()

	_ai.velocity = dir * _ai.movement_speed
	_ai.move_and_slide()
	_face(dir, delta)

## Turns toward a flat direction. Model faces -Z; use atan2(dir.x, dir.z) if it faces +Z.
func _face(dir: Vector3, delta: float) -> void:
	var target_yaw := atan2(-dir.x, -dir.z)
	_ai.rotation.y = rotate_toward(_ai.rotation.y, target_yaw, _ai.turn_speed * delta)