extends State

var _ai: AIActor

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Scanning requires an AIActor actor")
	
	_ai.face.material_override = preload("res://scenes/enemies/scanning_face_material.tres")

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	var opponents = _ai.get_opponents()
	
	for opponent in opponents:
		var ray := _ai.can_see_shoot(opponent)
		if ray.can_shoot:
			print("Can shoot ", opponent.name)
		elif ray.can_see:
			print("Can see ", opponent.name)
		else:
			print("-----------")
		
		if ray.can_shoot:
			if randf() < 0.04:
				#print(" [TRANS] SCAN -> ENGAGING")
				_ai.combat_target = opponent
				(get_parent() as StateMachine).transition_to($"../Engaging")
