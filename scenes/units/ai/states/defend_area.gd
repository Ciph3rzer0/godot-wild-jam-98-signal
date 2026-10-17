extends State

signal defended_area_breached(unit: Unit)

@export var defended_area: Area3D

var _ai: AIActor

func _ready():
	assert(defended_area, "Defend Area requires a configured Area3D")

## Called once when the state becomes active.
func enter() -> void:
	_ai = actor as AIActor
	assert(_ai != null, "Defend Area requires an AIActor actor")

## Called once when the state stops being active.
func exit() -> void:
	pass

## Called every frame while active.
func update(_delta: float) -> void:
	pass

## Called every physics frame while active.
func physics_update(_delta: float) -> void:
	for unit in defended_area.get_overlapping_bodies():
		if _ai.can_see_shoot(unit).can_see:
			defended_area_breached.emit(unit)
