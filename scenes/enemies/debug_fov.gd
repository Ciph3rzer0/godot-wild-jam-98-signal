@tool
extends MeshInstance3D

@export_range(0, 360) var arc_angle: float = 100.0 :
	set(value):
		arc_angle = value
		_draw_arc_and_wedge()

@export var radius: float = 2.0 :
	set(value):
		radius = value
		_draw_arc_and_wedge()

@export_range(1, 256) var segments: int = 32 :
	set(value):
		segments = maxi(value, 1)
		_draw_arc_and_wedge()

@export var line_color: Color = Color.CYAN :
	set(value):
		line_color = value
		_draw_arc_and_wedge()

@export var wedge_color: Color = Color(0.0, 1.0, 1.0, 0.25) : # Lower alpha for transparency
	set(value):
		wedge_color = value
		_draw_arc_and_wedge()

func _ready() -> void:
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_draw_arc_and_wedge()

func _draw_arc_and_wedge() -> void:
	if not is_node_ready():
		return  # setters fire during scene load; _ready() does the first build

	var imm_mesh := ImmediateMesh.new()

	var half_angle := deg_to_rad(arc_angle) / 2.0
	var points: Array[Vector3] = []
	for i in range(segments + 1):
		var a := lerpf(-half_angle, half_angle, float(i) / segments)
		points.append(Vector3(radius * sin(a), 0.0, -radius * cos(a)))

	# Wedge: one triangle per segment, all sharing the center
	var wedge_material := StandardMaterial3D.new()
	wedge_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	wedge_material.albedo_color = wedge_color
	wedge_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	wedge_material.cull_mode = BaseMaterial3D.CULL_DISABLED

	imm_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES, wedge_material)
	for i in range(segments):
		imm_mesh.surface_add_vertex(Vector3.ZERO)
		imm_mesh.surface_add_vertex(points[i])
		imm_mesh.surface_add_vertex(points[i + 1])
	imm_mesh.surface_end()

	# Outline: center -> arc -> center
	var line_material := StandardMaterial3D.new()
	line_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	line_material.albedo_color = line_color

	imm_mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, line_material)
	imm_mesh.surface_add_vertex(Vector3.ZERO)
	for pt in points:
		imm_mesh.surface_add_vertex(pt)
	if arc_angle < 360.0:
		imm_mesh.surface_add_vertex(Vector3.ZERO)
	imm_mesh.surface_end()

	mesh = imm_mesh
