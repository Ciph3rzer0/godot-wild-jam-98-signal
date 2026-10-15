extends RigidBody3D

@export var speed := 27.0

var target : Vector3

func set_target(_target: Vector3):
	target = _target
	look_at(_target, Vector3.UP)
	var forward_direction = -global_transform.basis.z
	linear_velocity = forward_direction * speed

func _ready() -> void:
	top_level = true

func _on_body_entered(body: Node) -> void:
	print(" BULLET HIT ", body.name)
	queue_free()
