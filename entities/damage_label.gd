extends Label3D

const tween_time = 0.5

@onready var timer = $Timer

var move_tween : Tween = null

func trigger(message):
	self.text = message
	move_tween = self.create_tween()
	move_tween.tween_property(self, "position", Vector3(0, 1, 0), tween_time)
	move_tween.tween_callback(_on_tween_end)


func _on_tween_end():
	timer.start()

func _on_timer_timeout():
	self.queue_free()
