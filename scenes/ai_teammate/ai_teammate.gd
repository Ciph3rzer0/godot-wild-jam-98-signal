class_name AITeammate
extends CharacterBody3D

@export var player: Player
@export var nav_agent: NavigationAgent3D

@export var patrol_markers: Array[Marker3D]

@export var movement_speed := 3.0
@export var turn_speed := 5.0

var _patrol_index: int
var _target: Node3D

func _ready() -> void:
	assert(player)
	assert(nav_agent)
	set_patrol_index(0)

func set_patrol_index(next: int):
	_patrol_index = next % patrol_markers.size()
	_target = patrol_markers[_patrol_index]
	nav_agent.target_position = _target.global_position
	$MoveTargetIndicator.global_position = _target.global_position

func _process(delta: float) -> void:
	match player.active_signal:
		HandSignalSprite.SIGNAL.STOP:
			$MovementState.transition_to($MovementState/Wait)
		HandSignalSprite.SIGNAL.SWAP:
			$MovementState.transition_to($MovementState/Patrol)
		HandSignalSprite.SIGNAL.HOLD:
			$MovementState.transition_to($MovementState/Follow)
	
	#
	#if nav_agent.is_navigation_finished():
		#set_patrol_index(_patrol_index + 1)
		#return
	#
	#
	## https://www.youutube.com/watch?v=cx49GTfLwZU
	#var dir := nav_agent.get_next_path_position() - global_position
	#dir.y = 0.0
	#if dir.length_squared() < 0.0001:
		#return
	#dir = dir.normalized()
	#
	#velocity = dir * movement_speed
	#move_and_slide()
	#
	## Model faces -Z (Godot default). If it faces +Z, use atan2(dir.x, dir.z).
	#var target_yaw := atan2(-dir.x, -dir.z)
	#rotation.y = rotate_toward(rotation.y, target_yaw, turn_speed * delta)
