class_name AIEnemy
extends CharacterBody3D

@export var player: Player
@export var good_guys: Array[AITeammate]

@export var movement_speed := 3.0
@export var turn_speed := 5.0


@export var sight_range := 20.0
@export var fov_deg := 100.0
## Layers that block vision: walls, terrain, closed doors. Leave out glass and foliage.
@export_flags_3d_physics var occluder_mask := 1

@onready var eyes: Node3D = $Face/Eyes  # Marker3D at head height, facing -Z


func _ready() -> void:
	assert(player)


func _process(delta: float) -> void:
	if can_see(player):
		print("Can see")
	else:
		print("-----------")
	#match player.active_signal:
		#HandSignalSprite.SIGNAL.STOP:
			#$MovementState.transition_to($MovementState/Wait)
		#HandSignalSprite.SIGNAL.SWAP:
			#$MovementState.transition_to($MovementState/Patrol)
		#HandSignalSprite.SIGNAL.HOLD:
			#$MovementState.transition_to($MovementState/Follow)
	
func can_see(target: Node3D) -> bool:
	var from := eyes.global_position
	# Check a couple of points so low cover doesn't hide a standing target.
	for point in [
								#target.global_position,
								target.global_position + Vector3.UP * 1.6,
								target.global_position + Vector3.UP * 0.9,
								]:
		if _point_visible(from, point):
			return true
	return false

func _point_visible(from: Vector3, to: Vector3) -> bool:
	var offset := to - from
	if offset.length_squared() > sight_range * sight_range:
		return false
	var forward := -eyes.global_basis.z
	if forward.dot(offset.normalized()) < cos(deg_to_rad(fov_deg * 0.5)):
		return false
	var query := PhysicsRayQueryParameters3D.create(from, to, occluder_mask, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()
