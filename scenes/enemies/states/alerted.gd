extends State

var _ai: AIEnemy

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIEnemy
	assert(_ai != null, "Scanning requires an AIEnemy actor")
	
	_ai.face.material_override = preload("res://scenes/enemies/alerted_face_material.tres")


## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	pass
