extends Node

var RELEASE := false 

var SET_DEBUG_DRAW_ON := true 
var SET_DEBUG_PRINT_ON := true 

var print_weapons_discharge := false:
	get:
		return !RELEASE and SET_DEBUG_PRINT_ON and print_weapons_discharge

var print_state_transitions := false:
	get:
		return !RELEASE and SET_DEBUG_PRINT_ON and print_state_transitions

var draw_player_los := false:
	get:
		return !RELEASE and SET_DEBUG_DRAW_ON and draw_player_los

var print_player_los := false:
	get:
		return !RELEASE and SET_DEBUG_PRINT_ON and print_player_los
