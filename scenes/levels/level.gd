class_name Level
extends Node

signal scenario_lost(reason: String)
signal scenario_won()


func _ready() -> void:
	GameManager.set_play_state(GameManager.PlayState.Playing)

func end_scenario_in_loss(reason: String):
	print("GAME OVER : " , reason)
	scenario_lost.emit(reason)

func end_scenario_in_win():
	scenario_won.emit()
