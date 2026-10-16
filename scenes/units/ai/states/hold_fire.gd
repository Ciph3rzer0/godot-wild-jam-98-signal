extends State

var _ai: AIActor

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Scanning requires an AIActor actor")
	
	if _ai.face:
		_ai.face.material_override = preload("uid://dx4vk1urlamo4")

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	pass
