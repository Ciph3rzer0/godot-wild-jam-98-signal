extends Control

func _ready() -> void:
	hide()
	
	for c in $"Radial Menu".get_children():
		if c.has_signal(&"selected"):
			c.selected.connect(selected_gesture)

func selected_gesture(gesture: HandSignalSprite.SIGNAL):
	print(str(HandSignalSprite.SIGNAL.find_key(gesture)))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		get_viewport().set_input_as_handled()
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				GameManager.paused_menu.set_mouse_free(true)
				show()
			else:
				GameManager.paused_menu.set_mouse_free(false)
				hide()
