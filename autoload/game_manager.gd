extends Node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	var game_over_screen: GameOverScreen = get_node("/root/Boot/Game Over Screen")
	#if event.is_action_pressed("ui_cancel"):
		#set_mouse_free(!is_mouse_free)
		#get_viewport().set_input_as_handled()
		#return
	#el
	if event.is_action_pressed("cheat_restart_level"):
		game_over_screen._reset_game_state()
		var error = get_tree().reload_current_scene()
		if error != OK:
			print("An error occurred while reloading the scene.")
