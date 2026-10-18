extends Node

signal play_state_changed(state: PlayState)

@onready var paused_menu: PausedMenu = get_node("/root/Boot/Paused Menu")

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

#func _input(event: InputEvent) -> void:
	#var game_over_screen: GameOverScreen = get_node("/root/Boot/Game Over Screen")
	#if event.is_action_pressed("cheat_restart_level"):
		#game_over_screen._reset_game_state()
		#var error = get_tree().reload_current_scene()
		#if error != OK:
			#print("An error occurred while reloading the scene.")
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("cheat_restart_level"):
		# var game_over_screen: GameOverScreen = get_node("/root/Boot/Game Over Screen")
		# game_over_screen._reset_game_state()
		var main := get_tree().current_scene as Main
		if main:
			main.restart_level()  # load_level() already resets game state
		else:
			# Level was run on its own (F6): there's no Main, so reload the level itself.
			get_tree().reload_current_scene()
		get_viewport().set_input_as_handled()
