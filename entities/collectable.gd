extends Area3D
class_name Collectable

@onready var collect_particles = $GPUParticles3D
@onready var dead_timer = $dead_timer
@onready var sprite = $Sprite3D

var id = 0
var is_collected = false
var is_seen = false

func _ready():
	print("COLLECTABLE ADDED TO WORLD")
	dead_timer.timeout.connect(_on_dead_timer_timeout)

func _on_body_entered(body):
	print("BODY ENTERED COLLECTAABLEE!!!!")
	if !is_collected:
		if body is PlayerController:
			body.collect_collectable(id)
			is_collected = true
			collect_particles.emitting = true
			dead_timer.start()
			sprite.visible = false
			if GameManager.minimap:
				GameManager.minimap.remove_collectable(get_current_tile())
			if GameManager.messages_manager:
				GameManager.messages_manager.show_message("You collected an ingredient!", 2.0)
			
			
func get_current_tile():
	return Vector2(self.global_position.x, self.global_position.z) / PlayerController.CELL_SIZE
	
	
	
func _physics_process(delta):
	if !is_seen:
		if can_see_player():
			print("CAN SEE PLAYER")
			if GameManager.minimap:
				GameManager.minimap.player_seen_collectable(get_current_tile())
				is_seen = true
				
							
				
				
func can_see_player():
	if GameManager.player:
		self.collision_layer = 0b0000
		var ray_start = self.global_position
		var ray_end = GameManager.player.global_position
		ray_end.y = 1
		ray_start.y = 1
		var world3d : World3D = get_world_3d()
		var space_state = world3d.direct_space_state
		if space_state == null:
			return null
		var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 0b1111)
		var tmp = space_state.intersect_ray(query)
		self.collision_layer = 0b1011
		if tmp:
			#print("COLLIDING ON PLAYER CHECK: " + str(tmp))
			if tmp.collider is PlayerController:
				return true
	return false
			
func _on_dead_timer_timeout():
	self.queue_free()
