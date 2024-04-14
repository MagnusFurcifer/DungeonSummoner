extends Control

@onready var label = $Label
@onready var label_timer = $Timer
# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.messages_manager = self
	label.visible = false
	label.text = ""


func show_message(message, time):
	label_timer.wait_time = time
	label.text = message
	label.visible = true
	label_timer.start()


func _on_timer_timeout():
	label.visible = false
	label.text = ""
	
