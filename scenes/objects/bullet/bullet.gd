extends RigidBody3D

@export var speed := 27.0
@export var damage := 55.0

var target : Vector3

func set_target(_target: Vector3):
	target = _target
	look_at(_target, Vector3.UP)
	var forward_direction = -global_transform.basis.z
	linear_velocity = forward_direction * speed

func _ready() -> void:
	top_level = true

func _on_body_entered(body: Node) -> void:
	if (body is Unit):
		print(" OBJECT HIT ", body.name)
		body.take_damage(damage, self)
	else:
		print(" BULLET HIT UNIT ", body.name)
	queue_free()
