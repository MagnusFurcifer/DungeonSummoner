extends CharacterBody3D
class_name PlayerController
@onready var systems = {
	"state" : $systems/state_system, ## scuffed state machine. Used by all other components to guide logic.
	"movement" : $systems/movement, ## Move and turn. Handles tweening and collision. 
	"cam" : $systems/camera_system, ## Literally just a camera with a few extra things
	}



const CELL_SIZE = 2

var visited_cells = []


var current_hp = 10
var max_hp = 10
var collectables_status = [
	false, 
	false, 
	false
]


signal updated_visited_tiles


func _ready():
	systems.state.setup(systems)
	systems.movement.setup(systems)
	systems.cam.setup(systems)
	GameManager.player = self

func _physics_process(_delta):
	if GameManager.is_playing():
		if systems.state.current_state == PlayerStates.PLAYER_STATES.DEAD:
			pass
		else:
			systems.movement.physics_process(_delta, self)
			systems.cam.physics_process(_delta, self)

func _process(delta):
	if GameManager.is_playing():
		if systems.state.current_state == PlayerStates.PLAYER_STATES.DEAD:
			pass
		else:
			pass

func _input(event):
	if GameManager.is_playing():
		if systems.state.current_state == PlayerStates.PLAYER_STATES.DEAD:
			pass
		else:
			systems.movement.input(event)
			systems.cam.input(event)
		
		
func heal(amount):
	current_hp += amount
	if current_hp >= max_hp:
		current_hp = max_hp
		
func has_all_collectables():
	var has_all = true
	for i in collectables_status:
		if !i:
			has_all = false
	return has_all
		
func collect_collectable(id):
	collectables_status[id] = true

func hit(dmg):
	print("HIT PLAYER")
	systems.cam.cam_shake()
	current_hp -= dmg
	$action_sfx/hit_audio.play()

func is_entity_in_front_cell():
	return systems.cam.cast_interact_ray()

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

