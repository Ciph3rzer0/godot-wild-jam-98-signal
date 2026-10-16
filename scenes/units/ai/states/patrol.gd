extends State

var _ai: AIActor
var _patrol_index: int
var _move_target: Node3D

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Patrol requires an AITeammate actor")
	# Re-apply the current waypoint so the agent drops whatever target the
	# previous state left behind (e.g. the player's position from Follow).
	set_patrol_index(_patrol_index)

## Called once when the state stops being active.
func exit() -> void:
	_ai.velocity = Vector3.ZERO

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(delta: float) -> void:
	if _ai.nav_agent.is_navigation_finished():
		set_patrol_index(_patrol_index + 1)
		return

	var dir: Vector3 = _ai.nav_agent.get_next_path_position() - _ai.global_position
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

func set_patrol_index(next: int):
	if !_ai.patrol_markers or !_ai.patrol_markers.size() > 0:
		return
	
	_patrol_index = next % _ai.patrol_markers.size()
	_move_target = _ai.patrol_markers[_patrol_index]
	_ai.nav_agent.target_position = _move_target.global_position
	_ai.get_node("MoveTargetIndicator").global_position = _move_target.global_position
