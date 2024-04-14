extends StaticBody3D


func activate():
	if GameManager.player:
		if GameManager.player.has_all_collectables():
			pass
		else:
			if GameManager.messages_manager:
				GameManager.messages_manager.show_message("You don't have all the ingredients needed to summon!", 1.5)
