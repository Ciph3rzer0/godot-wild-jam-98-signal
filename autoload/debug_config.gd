extends Node

var RELEASE := false 

var SET_DEBUG_DRAW_ON := true 
var SET_DEBUG_PRINT_ON := true 

var draw_player_los := false:
	get:
		return !RELEASE and SET_DEBUG_DRAW_ON and draw_player_los

var print_player_los := false:
	get:
		return !RELEASE and SET_DEBUG_DRAW_ON and print_player_los
