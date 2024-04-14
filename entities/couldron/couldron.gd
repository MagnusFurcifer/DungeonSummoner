extends StaticBody3D


func activate():
	if GameManager.player:
		if GameManager.player.has_all_collectables():
			get_tree().change_scene_to_file("res://screens/end_scene/end_screen.tscn")
		else:
			if GameManager.messages_manager:
				GameManager.messages_manager.show_message("You don't have all the ingredients needed to summon!", 1.5)
