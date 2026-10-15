class_name AIEnemy
extends CharacterBody3D

@export var player: Player
@export var opponents: Array[CharacterBody3D]

@export var movement_speed := 3.0
@export var turn_speed := 5.0


@export var sight_range := 20.0
@export var fov_deg := 100.0
## Layers that block vision: walls, terrain, closed doors. Leave out glass and foliage.
@export_flags_3d_physics var visual_occluder_mask := 1
@export_flags_3d_physics var attack_occluder_mask := 1

@export var bullet: PackedScene #RigidBody3D

@onready var face: CSGMesh3D = $Face 
@onready var eyes: MeshInstance3D = $Face/Eyes  # Marker3D at head height, facing -Z

var _primary_engagement_target: CharacterBody3D

func _ready() -> void:
	assert(player)
	assert(opponents)
	assert(opponents.size() > 0)
	assert(bullet)
	assert(face)
	assert(eyes)


func _process(delta: float) -> void:
	pass
	#match player.active_signal:
		#HandSignalSprite.SIGNAL.STOP:
			#$MovementState.transition_to($MovementState/Wait)
		#HandSignalSprite.SIGNAL.SWAP:
			#$MovementState.transition_to($MovementState/Patrol)
		#HandSignalSprite.SIGNAL.HOLD:
			#$MovementState.transition_to($MovementState/Follow)
	
func can_see_shoot(target: Node3D) -> RayTest:
	var ray := RayTest.new()
	
	var from := eyes.global_position
	# Check a couple of points so low cover doesn't hide a standing target.
	for point in [
								#target.global_position,
								target.global_position + Vector3.UP * 1.6,
								target.global_position + Vector3.UP * 0.9,
								]:
		if _point_visible(from, point, visual_occluder_mask):
			ray.can_see = true
			
		if _point_visible(from, point, attack_occluder_mask):
			ray.can_shoot = true
	
	if ray.can_shoot:
		debug_line_3d(from, target.global_position+ Vector3.UP * 0.9, Color.RED)
	elif ray.can_see:
		debug_line_3d(from, target.global_position+ Vector3.UP * 0.9, Color.YELLOW)
	
	return ray

#AI
func debug_line_3d(start: Vector3, end: Vector3, color: Color = Color.RED):
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()
	
	get_tree().root.add_child(mesh_instance)
	
	# Optional: Delete the line after a frame or brief moment if it updates constantly
	await get_tree().create_timer(0.2).timeout
	mesh_instance.queue_free()

func _point_visible(from: Vector3, to: Vector3, occluder_mask: int) -> bool:
	var offset := to - from
	if offset.length_squared() > sight_range * sight_range:
		return false
	var forward := -eyes.global_basis.z
	if forward.dot(offset.normalized()) < cos(deg_to_rad(fov_deg * 0.5)):
		return false
	var query := PhysicsRayQueryParameters3D.create(from, to, occluder_mask, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


class RayTest:
	var can_see: bool
	var can_shoot: bool
