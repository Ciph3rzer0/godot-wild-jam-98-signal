extends Node

signal play_state_changed(state: PlayState)

enum PlayState {
	Loading,
	Playing,
	GameOver,
	Paused,
}

var play_state := PlayState.Loading

func set_play_state(state: PlayState):
	play_state_changed.emit(state)
	play_state = state

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	var game_over_screen: GameOverScreen = get_node("/root/Boot/Game Over Screen")
	if event.is_action_pressed("cheat_restart_level"):
		game_over_screen._reset_game_state()
		var error = get_tree().reload_current_scene()
		if error != OK:
			print("An error occurred while reloading the scene.")
