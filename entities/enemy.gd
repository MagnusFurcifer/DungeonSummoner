extends Entity
class_name Enemy

const dmg_label = preload("res://entities/damage_label.tscn")

var current_hp = 10
var max_hp = 10

func hit(dmg_type):
	super(dmg_type)


func show_damage(dmg):
	var tmp = dmg_label.instantiate()
	add_child(tmp)
	tmp.trigger("-" + str(dmg))

func _process(delta):
	if current_state in [STATES.IDLE, STATES.ACTING]:
		if current_hp <= 0:
			die()
			
func _on_action_timer_finished():
	if current_state in [STATES.IDLE, STATES.ACTING]:
		#print("ACTION TIMER TIMEOUT")
		if is_player_adjacent():
			#print("PLAYER is ADJACENT")
			attack_player()
		else:
			var res = search_for_player()
			#print(res)
			if res:
				
				if res.collider is PlayerController:
					print("FOUND PLAYER IN RAY")
					var target_path = find_path_to_player()
					if target_path:
						print("FOUND TARGET PATH IN ASTAR")
						target_path.pop_front()
						if !is_player_adjacent():
							print("PLAYER NOT ADJACENT")
							move_towards_player(target_path)
			
			
func find_path_to_player():
	if GameManager.player and GameManager.world:
		var path = GameManager.world.astar_grid.get_id_path(get_current_tile(), GameManager.player.get_current_tile())
		return path

			
func attack_player():
	#print("ATTACK PLAYER")
	anim.play("attack")
	if GameManager.player:
		GameManager.player.hit(1)
			
func move_towards_player(target_path):
	var next_step = target_path.pop_front()
	if next_step:
		var target_tile = Vector3(next_step.x * PlayerController.CELL_SIZE, self.global_position.y, next_step.y * PlayerController.CELL_SIZE)
		var res = cast_ray_forward(target_tile)
		if !res:
			print("MOVED TOWARDS PLAYER: " + str(target_tile))
			self.global_position = target_tile
			
func cast_ray_forward(target_tile):
	self.collision_layer = 0b0000
	var ray_start = self.global_position
	var ray_end = target_tile
	var world3d : World3D = get_world_3d()
	var space_state = world3d.direct_space_state
	if space_state == null:
		return null
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, 0b1)
	var tmp = space_state.intersect_ray(query)
	self.collision_layer = 0b1011
	return tmp
			
func search_for_player():
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
		return tmp
		
func _on_animation_finished():
	super()
	if anim.animation == "attack":
		anim.play("idle")
