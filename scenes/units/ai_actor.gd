class_name AIActor
extends Unit

@export var nav_agent: NavigationAgent3D

@export var face: GeometryInstance3D
## Rotates independently of the body for scanning/aiming. Eyes should be a child of this.
@export var aim_pivot: Node3D
## At head height, facing -Z. Origin of sight and shooting rays.
@export var eyes: Node3D

@export_group("Movement")
@export var movement_speed := 3.0
@export var turn_speed := 5.0
@export var aim_turn_speed := 8.0

@export_group("Perception")
@export var sight_range := 20.0
@export var fov_deg := 100.0
## Layers that block vision: walls, terrain, closed doors. Leave out glass and foliage.
@export_flags_3d_physics var visual_occluder_mask := 1
## Layers that block shots.
@export_flags_3d_physics var attack_occluder_mask := 1
@export var debug_sight_lines := false

@export_group("AI")
@export var patrol_markers: Array[Marker3D]

## Set by FOLLOW commands; can be preassigned in the inspector.
@export var follow_target: Node3D
## Set by MOVE commands.
var move_target: SignalTarget
var combat_target: Unit

@onready var movement := $MovementState
@onready var combat := $CombatState

func _ready() -> void:
	super()
	assert(nav_agent)
	assert(aim_pivot)
	assert(eyes)


func receive_command(command: HandSignalSprite.SIGNAL, sender: Node3D, target: Variant = null) -> void:
	match command:
		HandSignalSprite.SIGNAL.STOP:
			movement.transition_to($MovementState/Wait)
		HandSignalSprite.SIGNAL.PATROL:
			movement.transition_to($MovementState/Patrol)
		HandSignalSprite.SIGNAL.FOLLOW:
			if !sender: return
			follow_target = sender
			movement.transition_to($MovementState/Follow)
		HandSignalSprite.SIGNAL.MOVE:
			if !target: return
			move_target = target
			movement.transition_to($MovementState/Move)
		HandSignalSprite.SIGNAL.ENGAGE:
			combat.transition_to($CombatState/Scanning)


## Turns the body toward a flat direction. Model faces -Z.
func face_direction(dir: Vector3, delta: float) -> void:
	if dir.length_squared() < 0.0001:
		return
	var target_yaw := atan2(-dir.x, -dir.z)
	rotation.y = rotate_toward(rotation.y, target_yaw, turn_speed * delta)


## Turns the aim pivot (and the eyes with it) toward a world point, relative to the body.
func aim_at(point: Vector3, delta: float) -> void:
	var local := to_local(point)
	var target_yaw := atan2(-local.x, -local.z)
	aim_pivot.rotation.y = rotate_toward(aim_pivot.rotation.y, target_yaw, aim_turn_speed * delta)


## Can we see and/or shoot a target?
func can_see_shoot(target: Unit) -> RayTest:
	var ray := RayTest.new()
	var from := eyes.global_position
	var forward := -eyes.global_basis.z
	var min_dot := cos(deg_to_rad(fov_deg * 0.5))

	for point in [
		target.global_position + Vector3.UP * 1.6,
		target.global_position + Vector3.UP * 0.9,
	]:
		var offset: Vector3 = point - from
		if offset.length_squared() > sight_range * sight_range:
			continue
		if forward.dot(offset.normalized()) < min_dot:
			continue
		if _is_ray_clear(from, point, visual_occluder_mask):
			ray.can_see = true
			if _is_ray_clear(from, point, attack_occluder_mask):
				ray.can_shoot = true
				break
	
	if debug_sight_lines and ray.can_see:
		debug_line_3d(from, target.global_position + Vector3.UP * 0.9,
				Color.RED if ray.can_shoot else Color.YELLOW)
	return ray

## Result of a can_see_shoot() test.
class RayTest:
	var can_see: bool
	var can_shoot: bool


## Determine if we have LOS to a target
func _is_ray_clear(from: Vector3, to: Vector3, mask: int) -> bool:
	var query := PhysicsRayQueryParameters3D.create(from, to, mask, [get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


## Draw a line for AI targeting debugging
func debug_line_3d(start: Vector3, end: Vector3, color: Color = Color.RED) -> void:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := StandardMaterial3D.new()
	mesh_instance.mesh = immediate_mesh
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(start)
	immediate_mesh.surface_add_vertex(end)
	immediate_mesh.surface_end()
	get_tree().root.add_child(mesh_instance)
	await get_tree().create_timer(0.2).timeout
	mesh_instance.queue_free()
