# signal_target.gd
class_name SignalTarget
extends Node3D

## Where selection aims. Defaults to this node's origin.
@export var aim_point: Node3D
## Meshes to outline when focused.
@export var highlight_meshes: Array[GeometryInstance3D] = []

static var _outline_mat: StandardMaterial3D


func _ready() -> void:
	add_to_group(&"signal_targets")


func get_aim_position() -> Vector3:
	return aim_point.global_position if aim_point else global_position


func set_highlighted(on: bool) -> void:
	var mat := _get_outline_material() if on else null
	for mesh in highlight_meshes:
		mesh.material_overlay = mat


func receive_signal(sig: int, from: Node) -> void:
	pass  # override per puzzle element


static func _get_outline_material() -> StandardMaterial3D:
	if not _outline_mat:
		_outline_mat = StandardMaterial3D.new()
		_outline_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_outline_mat.albedo_color = Color(1.0, 0.85, 0.2)
		_outline_mat.cull_mode = BaseMaterial3D.CULL_FRONT
		_outline_mat.grow = true
		_outline_mat.grow_amount = 0.03
	return _outline_mat
