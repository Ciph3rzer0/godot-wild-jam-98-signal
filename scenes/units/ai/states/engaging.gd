extends State

@export var avg_act_chance_per_second := 0.4

var _ai: AIActor

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Scanning requires an AIEnemy actor")
	
	if _ai.face:
		_ai.face.material_override = preload("uid://b0i4hgb4pcx8v")

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

var act_chance := -1.0

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	#if Engine.get_physics_frames()
	act_chance += avg_act_chance_per_second * _delta
	
	if randf() > act_chance: return
	act_chance -= 1 / avg_act_chance_per_second
	
	var opponent = _ai.combat_target
	
	var ray := _ai.can_see_shoot(opponent)
	if ray.can_shoot:
		#print("Engaging:: Can shoot ", opponent.name)
		shoot_at(opponent.global_position)
	elif ray.can_see:
		#print("Engaging:: Can see ", opponent.name)
		shoot_at(opponent.global_position)
	# else:
	# 	print("Engaging:: -----------")
	


func shoot_at(target: Vector3):
	if DEBUG.print_weapons_discharge:
		print(_ai.name, " SHOOT AT ", _ai.combat_target.name)
	var new_bullet := _ai.bullet.instantiate()
	get_tree().root.add_child(new_bullet)
	_ai.get_node("ShotSFX").play()
	_ai.play_shot_animation()
	new_bullet.global_position = _ai.gun_tip.global_position
	new_bullet.set_target(target + Vector3.UP * 0.9)
	#print(" [TRANS] ENGAGING -> SCAN")
	(get_parent() as StateMachine).transition_to($"../Scanning")
