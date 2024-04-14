extends Control

@onready var one = $ui_sprites/collectable_0
@onready var two = $ui_sprites/collectable_1
@onready var three = $ui_sprites/collectable_2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if GameManager.player:
		if GameManager.player.collectables_status[0]:
			one.play("full")
		else:
			one.play("empty")
		if GameManager.player.collectables_status[1]:
			two.play("full")
		else:
			two.play("empty")
		if GameManager.player.collectables_status[2]:
			three.play("full")
		else:
			three.play("empty")
