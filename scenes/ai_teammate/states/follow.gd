extends State

## How close to get before stopping.
@export var follow_distance := 2.5
## How much farther the player must get before the teammate starts moving again.
@export var resume_margin := 1.0
## How far the player must move before the path is recalculated.
@export var repath_distance := 0.5

var _ai: AITeammate
var _holding := false

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AITeammate
	assert(_ai != null, "FollowPlayer requires an AITeammate actor")
	_holding = false
	_ai.nav_agent.target_position = _ai.player.global_position

## Called once when the state stops being active.
func exit() -> void:
	_ai.velocity = Vector3.ZERO

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(delta: float) -> void:
	if _ai.player.active_signal == HandSignalSprite.SIGNAL.STOP:
		_ai.velocity = Vector3.ZERO
		return

	var player_pos: Vector3 = _ai.player.global_position
	var to_player := player_pos - _ai.global_position
	to_player.y = 0.0
	var dist := to_player.length()

	# Stop inside follow_distance; resume only once the player is clearly farther away.
	if _holding:
		if dist > follow_distance + resume_margin:
			_holding = false
	elif dist <= follow_distance:
		_holding = true

	if _holding:
		_ai.velocity = Vector3.ZERO
		_face(to_player, delta)
		return

	# Only re-path when the player has actually moved.
	if _ai.nav_agent.target_position.distance_to(player_pos) > repath_distance:
		_ai.nav_agent.target_position = player_pos

	if _ai.nav_agent.is_navigation_finished():
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
	if dir.length_squared() < 0.0001:
		return
	var target_yaw := atan2(-dir.x, -dir.z)
	_ai.rotation.y = rotate_toward(_ai.rotation.y, target_yaw, _ai.turn_speed * delta)
