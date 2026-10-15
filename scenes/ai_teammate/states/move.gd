extends State

## Emitted once when the teammate reaches move_target.
signal arrived

var move_target: SignalTarget

var _ai: AIActor
var _arrived := false

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Move requires an AIActor actor")
	
	move_target = _ai.move_target as SignalTarget
	assert(move_target != null, "Move requries a move_target")
	
	_arrived = false
	# Overwrite whatever target the previous state left on the agent.
	_ai.nav_agent.target_position = move_target.global_position

## Called once when the state stops being active.
func exit() -> void:
	_ai.velocity = Vector3.ZERO

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(delta: float) -> void:
	# Pick up a new destination if it changed while we're already moving.
	if not _ai.nav_agent.target_position.is_equal_approx(move_target.global_position):
		_ai.nav_agent.target_position = move_target.global_position
		_arrived = false

	if _ai.nav_agent.is_navigation_finished():
		_ai.velocity = Vector3.ZERO
		if not _arrived:
			_arrived = true
			arrived.emit()
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
