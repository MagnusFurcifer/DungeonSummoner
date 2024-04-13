extends Node3D
class_name CameraSystem


@onready var first_person_cam : Camera3D =  $first_person_cam
@onready var interact_ray : RayCast3D = $first_person_cam/interact_ray
@onready var debug_cam : Camera3D = $debug_free_cam

@onready var dither_filter = $first_person_cam/Control/dithering_filter

@export var mouse_sens : float = 3
@export var debug_cam_speed : float = 5

enum CAMS {
	FIRST_PERSON,
	DEBUG
}
@onready var selected_cam = CAMS.FIRST_PERSON
@onready var current_cam = first_person_cam
@onready var free_look_enabled = false 

var systems
func setup(a):
	systems = a
	first_person_cam.make_current()

	
func cam_shake():
	first_person_cam.add_stress(1.5)
	

	
func input(event):
	pass
	
	
func play_attack(item, is_hit):
	if item.is_melee():
		$first_person_cam/attack_sprite.play("attack")
	
	
func mouse_input(event):
	if free_look_enabled:
		if event is InputEventMouseMotion:
			current_cam.rotation.y -= event.relative.x / 1000 * mouse_sens
			current_cam.rotation.x -= event.relative.y / 1000 * mouse_sens
			current_cam.rotation.x = clamp(current_cam.rotation.x, PI/-2, PI/2)
						
#HACK - For keys and stuff, 
#where you use held items on objects in the world (such as keyholes)
#I'm not passing hte inpuit event from the drop event that happesn in the UI layer
#So this is kind of double handling with the mouse_input function above
func is_hovering_touchable(item):
	var tmp = cast_item_ray(get_viewport().get_mouse_position())
	if tmp:
		if tmp.collider.is_in_group("touchable"):
			print("CLICKED A TOUCHABLE OBJECT")
			tmp.collider.activate_with_held_item(item)
			return true
	return false
				
func cast_item_ray(m_pos):
	var ray_start = first_person_cam.project_ray_origin(m_pos)
	var ray_end = ray_start + first_person_cam.project_ray_normal(m_pos) * 3.85
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	if space_state == null:
		return null
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 0b010000)
	return space_state.intersect_ray(query)
	
	
	
	
func cast_interact_ray():
	if interact_ray.is_colliding():
		return interact_ray.get_collider()
	return null
	
func physics_process(delta, player_controller):
	input_poll()
	
	if selected_cam == CAMS.DEBUG:
		process_debug_cam_controls(delta)
	pass
	
func process_debug_cam_controls(delta):
	var direction = Vector3.ZERO
	var h_rot = current_cam.global_transform.basis.get_euler().y
	var f_input = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	var h_input = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction = Vector3(h_input, 0, f_input).rotated(Vector3.UP, h_rot).normalized()
	current_cam.global_position += (direction * delta) * debug_cam_speed
	
	if Input.is_action_pressed("move_turn_left"):
		current_cam.global_position += (Vector3.UP * delta) * debug_cam_speed
	elif Input.is_action_pressed("move_turn_right"):
		current_cam.global_position += (Vector3.DOWN * delta) * debug_cam_speed
		
		
func input_poll():
	if Input.is_action_just_pressed("action_freelook"):
		free_look_enabled = !free_look_enabled
		if !free_look_enabled:
			if selected_cam == CAMS.FIRST_PERSON:
				first_person_cam.rotation_degrees = Vector3(0, 180, 0)
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_VISIBLE)
		else:
			DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_CAPTURED)
			
			
			
			
func toggle_debug_cam():
	if selected_cam == CAMS.FIRST_PERSON:
		switch_cam(CAMS.DEBUG)
	else:
		switch_cam(CAMS.FIRST_PERSON)
			
				
				
	
func switch_cam(target_cam):
	if selected_cam == CAMS.FIRST_PERSON:
		first_person_cam.rotation_degrees = Vector3(0, 180, 0)
		
	match target_cam:
		CAMS.FIRST_PERSON:
			selected_cam = CAMS.FIRST_PERSON
			current_cam = first_person_cam
		CAMS.DEBUG:
			selected_cam = CAMS.DEBUG
			current_cam = debug_cam
	current_cam.current = true


