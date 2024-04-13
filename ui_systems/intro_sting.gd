extends Control

signal intro_finished

# Called when the node enters the scene tree for the first time.
func _ready():
	self.visible = false

func activate():
	self.visible = true
	$sting.play()
	$Timer.start()

func _on_timer_timeout():
	emit_signal("intro_finished")
	self.visible = false
