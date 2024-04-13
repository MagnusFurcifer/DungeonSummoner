extends Node3D
class_name PlayerStates
###################################################################################################
## PlayerStates
##
## This class is basically just a shitty state machine. 
##
###################################################################################################

## This holds the core player state around movement
## Is used by the _physics_process and input polling functions in the movement system primarily.
enum PLAYER_STATES {
	IDLE,
	MOVING,
	TURNING,
	ATTACKING,
	DEAD,
	DESCENDING,
}
## This holds the state as defined by the above enum
var current_state = PLAYER_STATES.IDLE

## This state is the actual game state and defines whether or not gameplay should be happening.
enum PLAYER_GAME_STATES {
	IN_MENU,
	IN_GAME
}
## This holds the state as defined by the above enum
var current_game_state = PLAYER_GAME_STATES.IN_GAME

## This is a standard part of the sub systems used by the [PlayerController] class to 
## provide access to specific refernces needed by subsystems.
var systems
func setup(a):
	systems = a
