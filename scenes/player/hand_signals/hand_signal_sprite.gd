@tool
class_name HandSignalSprite
extends Sprite3D

@export var current_signal := SIGNAL.NONE: set = _set_hand_signal

func _set_hand_signal(new_signal: SIGNAL):
	current_signal = new_signal
	
	visible = new_signal != SIGNAL.NONE
	if visible:
		frame = new_signal
	
	$Label3D.text = str(SIGNAL.find_key(new_signal))
	
enum SIGNAL {
	# Commands
	STOP = 0,
	HOLD,
	YES,
	NO,
	# Directions
	UP,
	FOLLOW, #DOWN,
	LEFT,
	MOVE, #RIGHT,
	# Counts
	ONE,
	TWO,
	THREE,
	FOUR,
	# Extras
	ENGAGE, #DaNGER,
	QUIET,
	SWAP,
	PATROL, #SLOW_DOWN,
	NONE = -1,
}
