extends Node


enum STATES {
	INTRO,
	PLAYING,
	DEAD
}

var current_state = STATES.INTRO

func set_state(state):
	current_state = state
	
func is_playing():
	return current_state == STATES.PLAYING
