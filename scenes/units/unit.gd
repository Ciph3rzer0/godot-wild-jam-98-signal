class_name Unit
extends CharacterBody3D

enum Team { FRIENDLY, HOSTILE, NEUTRAL }

signal damaged(amount: float, source: Node)
signal died

@export var team: Team
@export var max_health := 100.0

@export var gun_tip: Node3D
@export var bullet: PackedScene #RigidBody3D

var health: float

func is_alive(): return health > 0
func is_dead(): return health <= 0


func _ready() -> void:
	health = max_health
	add_to_group(team_group(team))
	
	died.connect(func():
		for child in find_children("*", "CollisionShape3D"):
			(child as CollisionShape3D).disabled = true 
		visible = false
	)


static func team_group(t: Team) -> StringName:
	return &"team_%d" % t


func is_opponent(other: Unit) -> bool:
	return other.team != team


func get_opponents() -> Array[Unit]:
	var result: Array[Unit] = []
	for t in Team.values():
		if t == Team.NEUTRAL: continue
		if t != team:
			for n in get_tree().get_nodes_in_group(team_group(t)):
				if n is Unit and n.is_alive():
					result.append(n)
	return result


## Points other units check for sight and aim at. Override if the unit's shape changes.
func get_target_points() -> Array[Vector3]:
	return [global_position + Vector3.UP * 1.6, global_position + Vector3.UP * 0.9]


func take_damage(amount: float, source: Node = null) -> void:
	health -= amount
	damaged.emit(amount, source)
	if health <= 0.0:
		died.emit()
