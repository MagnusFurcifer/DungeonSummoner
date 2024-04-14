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
				#print("FOUND PLAYER IN RAY")
				if res.collider is PlayerController:
					var target_path = find_path_to_player()
					if target_path:
						target_path.pop_front()
						if !is_player_adjacent():
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
	print("MOVING TOWARDS PLAYER")
	var target_dir = get_player_dir()
	
	var tgt_pos = Vector3(target_dir.x, 0, target_dir.y)
	self.global_position += tgt_pos
		
		
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
