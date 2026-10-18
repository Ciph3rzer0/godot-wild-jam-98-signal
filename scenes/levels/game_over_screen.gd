class_name GameOverScreen
extends Node

# main.gd
@export var game_over_screen: CanvasLayer
@export var game_over_panel: Control
@export var game_over_reason: Label

const SLOWDOWN_TIME := 1.0


func show_game_over(reason: String) -> void:
	game_over_reason.text = reason
	game_over_panel.modulate.a = 0.0
	game_over_screen.show()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	var tween := create_tween().set_ignore_time_scale(true).set_parallel()
	tween.tween_method(_set_time_scale, 1.0, 0.0, SLOWDOWN_TIME) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(game_over_panel, "modulate:a", 1.0, SLOWDOWN_TIME)
	tween.chain().tween_callback(_freeze)


func _set_time_scale(value: float) -> void:
	Engine.time_scale = value


func _freeze() -> void:
	get_tree().paused = true
	Engine.time_scale = 1.0  # paused now, so this doesn't un-freeze anything


func _reset_game_state() -> void:
	get_tree().paused = false
	Engine.time_scale = 1.0
	game_over_screen.hide()
