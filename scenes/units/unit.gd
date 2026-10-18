class_name Unit
extends CharacterBody3D

enum Team { FRIENDLY, HOSTILE, NEUTRAL }

signal damaged(amount: float, source: Node)
signal died

@export var team: Team
@export var max_health := 100.0

@export var gun_tip: Node3D
@export var bullet: PackedScene #RigidBody3D

@export_group("Animation")
@export var animator: CharacterAnimator

@export_group("Audio")
@export var hit_sound: AudioStream = preload("res://assets/audio/sfx/whomp.wav")
@export var death_sound: AudioStream = preload("res://assets/audio/sfx/whomp.wav")

var _hit_sfx: AudioStreamPlayer3D
var _death_sfx: AudioStreamPlayer3D
var health: float

func is_alive(): return health > 0
func is_dead(): return health <= 0


func _ready() -> void:
	health = max_health
	add_to_group(team_group(team))
	_hit_sfx = _get_or_create_sfx(&"HitSFX", hit_sound, -12.0)
	_death_sfx = _get_or_create_sfx(&"DeathSFX", death_sound, -8.0, 0.75)
	
	died.connect(func():
		_death_sfx.play()
		if animator:
			animator.active = false
		for child in find_children("*", "CollisionShape3D"):
			(child as CollisionShape3D).set_deferred("disabled", true)
		visible = false
	)


## supply defaults for every Unit instance.
func _get_or_create_sfx(node_name: StringName, stream: AudioStream, volume_db: float, pitch_scale := 1.0) -> AudioStreamPlayer3D:
	var sfx := get_node_or_null(NodePath(node_name)) as AudioStreamPlayer3D
	if sfx:
		return sfx
	sfx = AudioStreamPlayer3D.new()
	sfx.name = node_name
	sfx.stream = stream
	sfx.bus = &"SFX"
	sfx.volume_db = volume_db
	sfx.pitch_scale = pitch_scale
	sfx.max_polyphony = 4
	sfx.position.y = 1.0
	add_child(sfx)
	return sfx


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


func get_hostages() -> Array[Unit]:
	var result: Array[Unit] = []
	for n in get_tree().get_nodes_in_group(team_group(Team.NEUTRAL)):
		if n is Unit and n.is_alive():
			result.append(n)
	return result


## Points other units check for sight and aim at. Override if the unit's shape changes.
func get_target_points() -> Array[Vector3]:
	return [global_position + Vector3.UP * 1.6, global_position + Vector3.UP * 0.9]


func take_damage(amount: float, source: Node = null) -> void:
	if is_dead(): return
	health -= amount
	damaged.emit(amount, source)
	if health <= 0.0:
		died.emit()
	elif amount > 0.0:
		_hit_sfx.play()
