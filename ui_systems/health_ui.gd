extends Control

@onready var prog_bar = $ProgressBar

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.player:
		prog_bar.max_value = GameManager.player.max_hp
		prog_bar.value = GameManager.player.current_hp
