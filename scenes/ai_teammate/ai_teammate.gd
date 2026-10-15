class_name AITeammate
extends CharacterBody3D

@export var player: Player
@export var nav_agent: NavigationAgent3D

@export var patrol_markers: Array[Marker3D]

@export var movement_speed := 3.0
@export var turn_speed := 5.0

var _patrol_index: int
var _target: Node3D
var move_target: SignalTarget

func _ready() -> void:
	assert(player)
	assert(nav_agent)
	set_patrol_index(0)

func set_patrol_index(next: int):
	if !patrol_markers or !patrol_markers.size() > 0:
		return
	
	_patrol_index = next % patrol_markers.size()
	_target = patrol_markers[_patrol_index]
	nav_agent.target_position = _target.global_position
	$MoveTargetIndicator.global_position = _target.global_position

func _process(_delta: float) -> void:
	if player.actively_signaled_teammate == self:
		process_player_signals()

func process_player_signals():
	match player.active_signal:
		HandSignalSprite.SIGNAL.STOP:
			$MovementState.transition_to($MovementState/Wait)
		HandSignalSprite.SIGNAL.SWAP:
			$MovementState.transition_to($MovementState/Patrol)
		HandSignalSprite.SIGNAL.HOLD:
			$MovementState.transition_to($MovementState/Follow)
		HandSignalSprite.SIGNAL.DANGER:
			$MovementState.transition_to($MovementState/Move)

