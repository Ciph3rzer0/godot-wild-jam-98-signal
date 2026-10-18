extends State

@export var avg_act_chance_per_second := 1.0

var _ai: AIActor
var _hostage: Unit

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Kill Hostage requires an AIEnemy actor")
	
	if _ai.face:
		_ai.face.material_override = preload("uid://b0i4hgb4pcx8v")
	
	_hostage = _find_closest_hostage()
	assert(_hostage, "No hostage found")

func _find_closest_hostage() -> Unit:
	var best: Unit
	var best_dist := INF
	for hostage in _ai.get_hostages():
		var d := _ai.global_position.distance_squared_to(hostage.global_position)
		if d >= best_dist:
			continue
		if not _ai.can_see_shoot(hostage).can_shoot:
			continue
		best_dist = d
		best = hostage
	return best

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

var act_chance := -0.2

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	if !is_instance_valid(_hostage) or _hostage.is_dead():
		# Emit signal
		return
	
	act_chance += avg_act_chance_per_second * _delta
	
	if randf() > act_chance: return
	act_chance -= 1 / avg_act_chance_per_second
	
	var ray := _ai.can_see_shoot(_hostage)
	if ray.can_shoot:
		shoot_at(_hostage.global_position)


func shoot_at(target: Vector3):
	if DEBUG.print_weapons_discharge:
		print(_ai.name, " SHOOT AT HOSTAGE ", _hostage.name)
	_ai.get_node("ShotSFX").play()
	var new_bullet := _ai.bullet.instantiate()
	get_tree().root.add_child(new_bullet)
	new_bullet.global_position = _ai.gun_tip.global_position
	new_bullet.set_target(target + Vector3.UP * 0.9)
