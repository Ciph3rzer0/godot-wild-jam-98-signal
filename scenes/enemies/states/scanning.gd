extends State

var _ai: AIEnemy

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIEnemy
	assert(_ai != null, "Scanning requires an AIEnemy actor")

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	var opponents = _ai.opponents
	
	for opponent in opponents:
		var ray := _ai.can_see_shoot(opponent)
		if ray.can_shoot:
			print("Can shoot ", opponent.name)
		elif ray.can_see:
			print("Can see", opponent.name)
		else:
			print("-----------")
