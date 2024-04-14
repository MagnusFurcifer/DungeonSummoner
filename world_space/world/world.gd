extends Node3D

func create_world(dunGen):
	for meshes in dunGen.meshes:
		for mesh in meshes:
			add_child(mesh)
			
	for entity in dunGen.entities:
		add_child(entity)
	
	
	var s_loc = dunGen.get_player_spawn() * MeshBuilder.tileSize
	$player_controller.global_position = Vector3(s_loc.x, 0, s_loc.y)
