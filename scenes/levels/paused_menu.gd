class_name PausedMenu
extends CanvasLayer

@export var resume_button: Button
#var _paused_by_focus := false

var is_mouse_free := false

func _ready() -> void:
	set_mouse_free(false)

var exit_button_held_timer := 0.0
func _process(delta: float) -> void:
	if Input.is_action_pressed("ui_exit_game"):
		exit_button_held_timer += delta
		if (exit_button_held_timer) > 0.5:
			get_tree().quit()
	else:
		exit_button_held_timer = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()
		get_viewport().set_input_as_handled()
		return

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		# Don't take over an existing pause (game over, pause menu).
		if not get_tree().paused:
			pause_game()

func toggle_pause():
	if get_tree().paused:
		resume_from_focus_pause()
	else:
		pause_game()

func pause_game():
	if !GameManager.play_state == GameManager.PlayState.Playing:
		return
	get_tree().paused = true
	#_paused_by_focus = true
	show()
	set_mouse_free(get_tree().paused)
	GameManager.set_play_state(GameManager.PlayState.Paused)

func resume_from_focus_pause() -> void:
	if !GameManager.play_state == GameManager.PlayState.Paused:
		return
	#if not _paused_by_focus:
		#return
	#_paused_by_focus = false
	hide()
	get_tree().paused = false
	set_mouse_free(get_tree().paused)
	GameManager.set_play_state(GameManager.PlayState.Playing)

func set_mouse_free(val: bool):
	is_mouse_free = val
	if val:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
