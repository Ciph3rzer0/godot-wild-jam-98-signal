extends State

## Called once when the state becomes active.
func enter() -> void:
	assert(actor is AITeammate)

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(delta: float) -> void:
	if actor.player.active_signal == HandSignalSprite.SIGNAL.STOP:
		return
	
	if actor.nav_agent.is_navigation_finished():
		actor.set_patrol_index(actor._patrol_index + 1)
		return
	
	
	# https://www.youutube.com/watch?v=cx49GTfLwZU
	var dir: Vector3 = actor.nav_agent.get_next_path_position() - actor.global_position
	dir.y = 0.0
	if dir.length_squared() < 0.0001:
		return
	dir = dir.normalized()
	
	actor.velocity = dir * actor.movement_speed
	actor.move_and_slide()
	
	# Model faces -Z (Godot default). If it faces +Z, use atan2(dir.x, dir.z).
	var target_yaw := atan2(-dir.x, -dir.z)
	actor.rotation.y = rotate_toward(actor.rotation.y, target_yaw, actor.turn_speed * delta)
