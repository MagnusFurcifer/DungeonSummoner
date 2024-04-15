extends Control


func _ready():
	self.visible = false
	$TextureRect/ColorRect/Label.visible = false
	$TextureRect/ColorRect/Label2.visible = false

func start():
	$AudioStreamPlayer.play()
	$Timer.start()
	$TextureRect/ColorRect/Label.visible = true

func change():
	get_tree().change_scene_to_file("res://screens/game_screen/game_screen.tscn")


func _on_timer_timeout():
	$AudioStreamPlayer.play()
	$TextureRect/ColorRect/Label2.visible = true
	$Timer2.start()


func _on_timer_2_timeout():
	change()
