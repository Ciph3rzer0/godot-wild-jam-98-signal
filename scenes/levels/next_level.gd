class_name LevelLoadTrigger
extends Area3D

## Level to load when the player enters.
@export_file("*.tscn") var next_level: String

var _triggered := false


func _ready() -> void:
	assert(not next_level.is_empty(), "%s has no next_level set" % name)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if _triggered or not body is Player:
		return
	_triggered = true
	# Deferred: body_entered fires during the physics step, and the old level
	# gets freed during the load.
	_load.call_deferred()


func _load() -> void:
	var main := get_tree().current_scene as Main
	if main:
		main.load_level(next_level)
	else:
		# Level was run on its own (F6), so there's no Main to load into.
		get_tree().change_scene_to_file(next_level)
