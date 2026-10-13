extends CharacterBody3D

@export var player: Player
@export var nav_agent: NavigationAgent3D

@export var patrol_markers: Array[Marker3D]

@export var movement_speed := 10.0

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
	if player.active_signal == HandSignalSprite.SIGNAL.STOP: return
	
	if nav_agent.is_target_reached():
		set_patrol_index(_patrol_index + 1)
	else:
		# https://www.youtube.com/watch?v=cx49GTfLwZU
		var nav_point_direction = to_local(nav_agent.get_next_path_position()).normalized()
	
		velocity = nav_point_direction * movement_speed * delta
		move_and_slide()
