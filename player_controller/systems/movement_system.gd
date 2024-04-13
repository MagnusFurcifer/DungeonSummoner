extends Node3D
class_name MovementSystem


####Nodes
@onready var movement_ray = $movement_ray
@onready var wall_area_ray = $wall_area_ray
@onready var footsteps = $footsteps_system


@export var move_tween_duration : float = 0.25
@export var turn_tween_duration : float = 0.25
@export var bounce_coe : float = 0.1


enum ACTIONS {
	IDLE,
	MOVE,
	TURN,
}

enum DIRS {
	UP,
	DOWN,
	LEFT,
	RIGHT
}
var current_dir : int = DIRS.UP

#Status Flags
var move_tween_active = false
var turn_tween_active = false
var tween_target_tile = null

var visited_tiles = []


var external_action = null #This is called if the player is made to move externally, such as via the buttons in the UI

var systems
func setup(a):
	systems = a

func input(_event):
	pass
	
	
	
func set_inital_rotation(player_controller, start_dir):
	current_dir = start_dir.dir
	player_controller.rotation_degrees = start_dir.rotation
	
	
func physics_process(_delta, player_controller):
	if systems.cam.selected_cam == CameraSystem.CAMS.FIRST_PERSON:
		if !systems.cam.free_look_enabled:
			process_in_game_movement(_delta, player_controller)
			
	footsteps.physics_process(_delta, player_controller, self)
	
func process_in_game_movement(_delta, player_controller):
	var queued_action = ACTIONS.IDLE
	var action = null
	
	if external_action: #This is set by an external thing that wants the player ot move (Like the UI Buttons)
		action = external_action
		external_action = null #Null out the ext action so that it doesn't loop 
	else:
		#We always poll for input, so we can inturrupt 
		action = input_poll(player_controller)
		
	#This processes the input or externally queuec action and returns an action that can be processec by movement
	queued_action = process_action(action, player_controller)
	#Process queued action
	if queued_action.action == ACTIONS.MOVE:
		if systems.state.current_state == PlayerStates.PLAYER_STATES.IDLE:
			systems.state.current_state = PlayerStates.PLAYER_STATES.MOVING
	elif queued_action.action == ACTIONS.TURN:
		if systems.state.current_state == PlayerStates.PLAYER_STATES.IDLE:
			systems.state.current_state = PlayerStates.PLAYER_STATES.TURNING
	
	match systems.state.current_state:
		PlayerStates.PLAYER_STATES.MOVING:
			if !move_tween_active:
				var collision_test = is_colliding(player_controller, queued_action)
				if collision_test:
						var move_tween = get_tree().create_tween()
						move_tween.tween_property(player_controller, "global_position", player_controller.global_position + (queued_action.move_diff * bounce_coe), move_tween_duration)
						move_tween.tween_callback(self._on_bounce_tween_finished.bind(player_controller, player_controller.global_position))
						move_tween_active = true
				else:
					var move_tween = get_tree().create_tween()
					move_tween.tween_property(player_controller, "global_position", player_controller.global_position + queued_action.move_diff, move_tween_duration)
					move_tween.tween_callback(self._on_move_tween_finished.bind(player_controller))
					move_tween_active = true
					var target_pos = player_controller.global_position + queued_action.move_diff
					tween_target_tile = Vector2(target_pos.x, target_pos.z) / PlayerController.CELL_SIZE
					
					update_visited_tiles(player_controller,player_controller.global_position + queued_action.move_diff)
					
		PlayerStates.PLAYER_STATES.TURNING:
			if !turn_tween_active:
				var turn_tween = get_tree().create_tween()
				turn_tween.tween_property(player_controller, "rotation_degrees", queued_action.target_rotation, turn_tween_duration)
				turn_tween.tween_callback(self._on_turn_tween_finished.bind(player_controller, queued_action.target_dir))
				turn_tween_active = true
			

func is_entering_wall_area(player_controller, queued_action):
	if current_dir == DIRS.UP:
		wall_area_ray.target_position = queued_action.move_diff
	if current_dir == DIRS.DOWN:
		wall_area_ray.target_position = -queued_action.move_diff
	if current_dir == DIRS.LEFT:
		wall_area_ray.target_position = Vector3(-queued_action.move_diff.z, 0, queued_action.move_diff.x) 
	if current_dir == DIRS.RIGHT:
		wall_area_ray.target_position = Vector3(queued_action.move_diff.z, 0, -queued_action.move_diff.x) 
	wall_area_ray.force_raycast_update()
	if wall_area_ray.is_colliding():
		return wall_area_ray.get_collider()
	else:
		return false			
			
func is_colliding(player_controller, queued_action):
	#print("CALLING IS COLLIDING")
	#print(queued_action)
	if current_dir == DIRS.UP:
		movement_ray.target_position = queued_action.move_diff
	if current_dir == DIRS.DOWN:
		movement_ray.target_position = -queued_action.move_diff
	if current_dir == DIRS.LEFT:
		movement_ray.target_position = Vector3(-queued_action.move_diff.z, 0, queued_action.move_diff.x) 
	if current_dir == DIRS.RIGHT:
		movement_ray.target_position = Vector3(queued_action.move_diff.z, 0, -queued_action.move_diff.x) 
	movement_ray.force_raycast_update()
	if movement_ray.is_colliding():
		return movement_ray.get_collider()
	else:
		return false
		
		
		
#This is called by an external object/system and just queues up a movement action
#that will be played on the next physics upodate
func ext_move_player(dir):
	external_action = dir
	
func input_poll(player_controller):
	var action = null
	
	
	#HACK  - this is literally just so I can lock input from the 
	#map screen in the game_screen UI layout because otherwise when you type
	#notes onto the map screen, the character moves and it's weird
	var enabled = true

	if enabled:
		if Input.is_action_pressed("move_forward"): action = "move_forward"
		if Input.is_action_pressed("move_backward"): action = "move_backward"
		if Input.is_action_pressed("move_left"): action = "move_left"
		if Input.is_action_pressed("move_right"): action = "move_right"
		if Input.is_action_pressed("move_turn_left"): action = "move_turn_left"
		if Input.is_action_pressed("move_turn_right"): action = "move_turn_right"
		
	return action
	
func process_action(action, player_controller):
	#print("PROCESS ACTION")
	#print(action)
	var queued_action = {
		"action" : ACTIONS.IDLE,
		"move_vector" : null,
		"move_diff" : null,
		"target_dir": null,
		"target_rotation" : null,
	}
	
	if action == "move_forward":
		queued_action.action = ACTIONS.MOVE
		if current_dir == DIRS.UP:
			queued_action.move_diff = Vector3(0, 0, player_controller.CELL_SIZE)
		elif current_dir == DIRS.DOWN:
			queued_action.move_diff = Vector3(0, 0, -player_controller.CELL_SIZE)
		elif current_dir == DIRS.LEFT:
			queued_action.move_diff = Vector3(player_controller.CELL_SIZE, 0, 0)
		elif current_dir == DIRS.RIGHT:
			queued_action.move_diff = Vector3(-player_controller.CELL_SIZE, 0, 0)
		queued_action.move_vector = player_controller.global_position + queued_action.move_diff
	elif action == "move_backward":
		queued_action.action = ACTIONS.MOVE
		if current_dir == DIRS.UP:
			queued_action.move_diff = Vector3(0, 0, -player_controller.CELL_SIZE)
		elif current_dir == DIRS.DOWN:
			queued_action.move_diff = Vector3(0, 0, player_controller.CELL_SIZE)
		elif current_dir == DIRS.LEFT:
			queued_action.move_diff = Vector3(-player_controller.CELL_SIZE, 0, 0)
		elif current_dir == DIRS.RIGHT:
			queued_action.move_diff = Vector3(player_controller.CELL_SIZE, 0, 0)
		queued_action.move_vector = player_controller.global_position + queued_action.move_diff
	elif action == "move_left":
		queued_action.action = ACTIONS.MOVE
		if current_dir == DIRS.UP:
			queued_action.move_diff = Vector3(player_controller.CELL_SIZE, 0, 0)
		elif current_dir == DIRS.DOWN:
			queued_action.move_diff = Vector3(-player_controller.CELL_SIZE, 0, 0)
		elif current_dir == DIRS.LEFT:
			queued_action.move_diff = Vector3(0, 0, -player_controller.CELL_SIZE)
		elif current_dir == DIRS.RIGHT:
			queued_action.move_diff = Vector3(0, 0, player_controller.CELL_SIZE)
		queued_action.move_vector = player_controller.global_position + queued_action.move_diff	
	elif action == "move_right":
		queued_action.action = ACTIONS.MOVE
		if current_dir == DIRS.UP:
			queued_action.move_diff = Vector3(-player_controller.CELL_SIZE, 0, 0)
		elif current_dir == DIRS.DOWN:
			queued_action.move_diff = Vector3(player_controller.CELL_SIZE, 0, 0)
		elif current_dir == DIRS.LEFT:
			queued_action.move_diff = Vector3(0, 0, player_controller.CELL_SIZE)
		elif current_dir == DIRS.RIGHT:
			queued_action.move_diff = Vector3(0, 0, -player_controller.CELL_SIZE)
		queued_action.move_vector = player_controller.global_position + queued_action.move_diff	
	elif action == "move_turn_left":
		queued_action.action = ACTIONS.TURN
		queued_action.target_rotation = player_controller.rotation_degrees + Vector3(0, 90, 0)
		if current_dir == DIRS.UP:
			queued_action.target_dir = DIRS.LEFT
		elif current_dir == DIRS.DOWN:
			queued_action.target_dir = DIRS.RIGHT
		elif current_dir == DIRS.LEFT:
			queued_action.target_dir = DIRS.DOWN
		elif current_dir == DIRS.RIGHT:
			queued_action.target_dir = DIRS.UP
	elif action == "move_turn_right":
		queued_action.action = ACTIONS.TURN
		queued_action.target_rotation = player_controller.rotation_degrees + Vector3(0, -90, 0)
		if current_dir == DIRS.UP:
			queued_action.target_dir = DIRS.RIGHT
		elif current_dir == DIRS.DOWN:
			queued_action.target_dir = DIRS.LEFT
		elif current_dir == DIRS.LEFT:
			queued_action.target_dir = DIRS.UP
		elif current_dir == DIRS.RIGHT:
			queued_action.target_dir = DIRS.DOWN

	#print(queued_action)

	return queued_action
	
	

func get_cell_infront_of_player_global_position(player_controller):
	var target_cell_diff
	if current_dir == DIRS.UP:
		target_cell_diff = Vector3(0, 0, player_controller.CELL_SIZE)
	elif current_dir == DIRS.DOWN:
		target_cell_diff = Vector3(0, 0, -player_controller.CELL_SIZE)
	elif current_dir == DIRS.LEFT:
		target_cell_diff = Vector3(player_controller.CELL_SIZE, 0, 0)
	elif current_dir == DIRS.RIGHT:
		target_cell_diff = Vector3(-player_controller.CELL_SIZE, 0, 0)
	var target_cell = player_controller.global_position + target_cell_diff
		
	return target_cell
		
#################CALL BACKS



func _on_turn_tween_finished(player_controller, target_dir):
	current_dir = target_dir
	#Set the dir to within 360 so that we don't drift
	if current_dir == DIRS.UP:
		player_controller.rotation_degrees = Vector3(0, 0, 0)
	elif current_dir == DIRS.DOWN:
		player_controller.rotation_degrees = Vector3(0, -180, 0)
	elif current_dir == DIRS.LEFT:
		player_controller.rotation_degrees = Vector3(0, 90, 0)
	elif current_dir == DIRS.RIGHT:
		player_controller.rotation_degrees = Vector3(0, 270, 0)
	
	systems.state.current_state = PlayerStates.PLAYER_STATES.IDLE
	turn_tween_active = false
		

func _on_bounce_tween_finished(player_controller, original_pos):
	var move_tween = get_tree().create_tween()
	move_tween.tween_property(player_controller, "global_position", original_pos, move_tween_duration)
	move_tween.tween_callback(self._on_move_tween_finished.bind(player_controller))

		
func _on_move_tween_finished(player_controller):
	player_controller.log_current_cell()
	systems.state.current_state = PlayerStates.PLAYER_STATES.IDLE
	move_tween_active = false
	tween_target_tile = null

		
func update_visited_tiles(player_controller, tile):
	var map_pos = Vector2(tile.x, tile.z) / PlayerController.CELL_SIZE
	var exists = false
	for i in visited_tiles:
		if i == map_pos:
			exists = true
	if !exists:
		visited_tiles.append(map_pos)
	player_controller.emit_signal("updated_visited_tiles")
	

