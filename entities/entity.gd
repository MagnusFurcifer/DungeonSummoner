extends CharacterBody3D
class_name Entity

@onready var anim = $AnimatedSprite3D
@onready var col_shape = $CollisionShape3D
@onready var action_timer = $action_timer

enum STATES {
	IDLE,
	ACTING,
	DYING,
	DEAD
}
var current_state = STATES.IDLE

func _ready():
	anim.animation_finished.connect(_on_animation_finished)
	action_timer.timeout.connect(_on_action_timer_finished)
	action_timer.start()
	anim.play("idle")

func hit(dmg_type):
	if current_state in [STATES.IDLE, STATES.ACTING]:
		anim.play("hit")
	
	
func die():
	if current_state in [STATES.IDLE, STATES.ACTING]:
		current_state = STATES.DYING
		anim.play("death")
		
		
		
func get_current_tile():
	return Vector2(self.global_position.x, self.global_position.z) / PlayerController.CELL_SIZE
	
	
func get_player_dir():
	print("Getting Player Dir")
	var dir = Vector2(0, 0)
	if GameManager.player:
		var ec = get_current_tile()
		var pc = GameManager.player.get_current_tile()
		var x_diff = abs(pc.x-ec.x)
		var y_diff = abs(pc.y-ec.y)
		if x_diff > y_diff:
			if ec.x < pc.x:
				dir.x = 1
			else:
				dir.x = -1
		else:
			if ec.y < pc.y:
				dir.y = 1
			else:
				dir.y = -1
				
	print("Player Dir: " + str(dir))
	return dir
	
func is_player_adjacent():
	if GameManager.player:
		var ec = get_current_tile()
		var pc = GameManager.player.get_current_tile()
		var x_diff = abs(pc.x-ec.x)
		var y_diff = abs(pc.y-ec.y)
		if x_diff <= 1 and y_diff <= 1:
			if x_diff == 1 and y_diff == 0:
				return true
			elif y_diff == 1 and x_diff == 0:
				return true
	return false
	
	
func _on_animation_finished():
	if anim.animation == "death":
		current_state == STATES.DEAD
		anim.play("dead")
		col_shape.disabled = true
		
		
func _on_action_timer_finished():
	pass
	
