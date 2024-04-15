extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$main_menu.visible = false
	$Timer1.start()


func _on_button_pressed():
	get_tree().change_scene_to_file("res://screens/main_menu_screen/main_menu_screen.tscn")


func _on_timer_1_timeout():
	$intro_cut_scene/AnimatedSprite2D.play("play")


func _on_animated_sprite_2d_animation_finished():
	if $intro_cut_scene/AnimatedSprite2D.animation == "play":
		$intro_cut_scene/AnimatedSprite2D.play("idle")
		$main_menu.visible = true
