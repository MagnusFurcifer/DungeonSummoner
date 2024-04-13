extends Control

@onready var world_container = $world_container

var dunGen = DungeonGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.set_state(GameManager.STATES.INTRO)
	dunGen.create_dungeon()
	world_container.create_world(dunGen)
	$start_timer.start()
	
	
func _on_intro_sting_intro_finished():
	GameManager.set_state(GameManager.STATES.PLAYING)
	$cards.activate()


func _on_start_timer_timeout():
	$intro_sting.activate()
