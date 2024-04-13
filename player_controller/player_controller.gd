extends CharacterBody3D
class_name PlayerController
########################################################
## Player Controller
## 
## Player controller that implements systems such as movement, ui, and camera via subsystesm
## managed by this node during the built-in functions
## 
#######################################################
## Dictionary containing references to the system nodes. 
## These systems are called in the _process, _physics_process, and _input methods to alloy overriding
## based on gamestate. 
@onready var systems = {
	"state" : $systems/state_system, ## scuffed state machine. Used by all other components to guide logic.
	"movement" : $systems/movement, ## Move and turn. Handles tweening and collision. 
	"cam" : $systems/camera_system, ## Literally just a camera with a few extra things
	}
## cell size of the gridmap meshes (godot meters).
## The gridmap should be made up of meshes in the mesh library that are a vector2i of this value
## nonsquare gridmap cells are not supported or everything breaks.....everything
## ......this should be in a singleton or something, but I want the pc to be extendable to differnt gridmaps
const CELL_SIZE = 2


## visited cells is updated when movement tween ends to provide an easy way to automap. 
## Updated from movement subsystem and used in the UISystem subsystem
var visited_cells = []


signal updated_visited_tiles


## On ready we need to load gridmap and then to setup all the subsystems.
## This provides the nessecary refs for the subsystem to interact
func _ready():
	systems.state.setup(systems)
	systems.movement.setup(systems)
	systems.cam.setup(systems)

###################################################################################################
## Built in _physics_process that runs every physics frame
##
## Is just used to kick off the physics process of relevent subsystems
##
###################################################################################################
func _physics_process(_delta):
	if GameManager.is_playing():
		if systems.state.current_state == PlayerStates.PLAYER_STATES.DEAD:
			pass
		else:
			systems.movement.physics_process(_delta, self)
			systems.cam.physics_process(_delta, self)

###################################################################################################
## Built in _process that runs every frame
##
## Is just used to kick off the process of relevent subsystems
##
###################################################################################################	
func _process(delta):
	if GameManager.is_playing():
		if systems.state.current_state == PlayerStates.PLAYER_STATES.DEAD:
			pass
		else:
			pass

###################################################################################################
## Built in _input that runs every time there is an input event triggered
##
## This is primarily used by the ui and stats subsystems to control complex UI functions
##
###################################################################################################	
func _input(event):
	if GameManager.is_playing():
		if systems.state.current_state == PlayerStates.PLAYER_STATES.DEAD:
			pass
		else:
			systems.movement.input(event)
			systems.cam.input(event)
		
###################################################################################################
## helper functions
##
## Adds the current cells to the visited_cells array for use in auto-mapping
##
###################################################################################################

func set_inital_rotation(start_dir):
	systems.movement.set_inital_rotation(self, start_dir)
	pass

func toggle_debug_cam():
	systems.cam.toggle_debug_cam()

func get_visited_tiles():
	return systems.movement.visited_tiles

func get_front_tile():
	pass

func log_current_cell():
	pass
	
func get_current_tile():
	return Vector2(
				int(self.global_position.x / CELL_SIZE), 
				int(self.global_position.z / CELL_SIZE) 
			)
	
func is_infront(entity):
	pass

