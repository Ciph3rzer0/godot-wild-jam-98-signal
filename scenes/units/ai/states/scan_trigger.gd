extends State

var _ai: AIActor

signal target_acquired(target: Unit)

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
func physics_update(delta: float) -> void:
	var opponents = _ai.get_opponents()
	
	for opponent in opponents:
		var ray := _ai.can_see_shoot(opponent)
		if ray.can_shoot:
			if randf() < 0.04:
				_ai.combat_target = opponent
				print ("Target acquired")
				target_acquired.emit(opponent)
				# (get_parent() as StateMachine).transition_to($"../Engaging")
	
	_ai.apply_gravity(delta)
	_ai.move_and_slide()
