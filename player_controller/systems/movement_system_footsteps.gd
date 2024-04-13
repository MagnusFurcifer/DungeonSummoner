extends Node3D
class_name FootstepSystem

var fs_array = [preload("res://player_controller/assets/sfx/footsteps/sound.wav"),
				preload("res://player_controller/assets/sfx/footsteps/sound2.wav"),
				preload("res://player_controller/assets/sfx/footsteps/sound3.wav"),
				preload("res://player_controller/assets/sfx/footsteps/sound4.wav")]
				
				
@onready var fs_timer = $footstep_delay
@onready var fs_ap = $footstep_player


func _ready():
	randomize()
	

func physics_process(_delta, player_controller, movement_system):
	if movement_system.move_tween_active:
		#print("FOOTSTEPS")
		if fs_timer.time_left <= 0:
			fs_ap.stream = fs_array[randi() % fs_array.size()]
			fs_ap.play()
			fs_timer.start()





