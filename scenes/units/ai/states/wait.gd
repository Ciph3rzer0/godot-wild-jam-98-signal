extends State

var _ai: AIActor


## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Move requires an AIActor actor")

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(delta: float) -> void:
	_ai.apply_gravity(delta)
