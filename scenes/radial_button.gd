extends Control

signal selected(gesture: HandSignalSprite.SIGNAL)

@export var gesture := HandSignalSprite.SIGNAL.NONE

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			# Check if the global mouse position falls inside this Control's global bounds
			if get_global_rect().has_point(get_global_mouse_position()):
				selected.emit(gesture)
