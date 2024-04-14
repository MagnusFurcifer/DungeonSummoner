extends Node


enum STATES {
	INTRO,
	PLAYING,
	DEAD
}

var current_state = STATES.INTRO

var player = null
var minimap = null
var messages_manager = null
var world = null

func set_state(state):
	current_state = state
	
func is_playing():
	return current_state == STATES.PLAYING
