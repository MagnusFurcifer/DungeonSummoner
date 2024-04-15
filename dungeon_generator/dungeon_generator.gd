extends Node
class_name DungeonGenerator

const MAP_SIZE = Vector2(24, 24)

enum CELL_TYPES {
	BLANK,
	BLANK_ROOM,
	BLANK_HALL,
	BRICK_WALL,
	DOOR,
}

var mat_man = MaterialManager.new()
var map = MapGenerator.new()

var rooms = []
var meshes = []
var entities = []
var player_spawn = Vector2(0, 0)


@export var room_min_size : Vector2 = Vector2(2, 2)
@export var room_max_size : Vector2 = Vector2(4, 4)
@export var min_rooms_num : int = 3
@export var max_rooms_num : int = 6


var max_tries = 10
var tries = 0

func create_dungeon():
	var success = false
	while tries < max_tries || !success: 
		map.generate_level(MAP_SIZE)
		generate_meshes()
		if test_map():
			success = true
			break
		tries += 1
	
func test_map():
	if meshes.size() > 1:
		return true
	return false
	
func get_player_spawn():
	return map.spawn
	
	
func get_couldron_spawn():
	return map.couldron
	
	
func generate_meshes():
	print("Generate Meshes")
	var mb = MeshBuilder.new()
	var block_arrays : Dictionary = {}
	var blank_array = []
	for y in map.get_map().size():
		for x in map.get_map()[y].size():
			if map.get_map()[y][x].type == CELL_TYPES.BLANK:
				blank_array.append(Vector2(y, x))
			elif map.get_map()[y][x].type == CELL_TYPES.BLANK_HALL:
				blank_array.append(Vector2(y, x))
				instanite_entities(map.get_map()[y][x], y, x)
							
			elif map.get_map()[y][x].type == CELL_TYPES.BLANK_ROOM:
				blank_array.append(Vector2(y, x))
				instanite_entities(map.get_map()[y][x], y, x)
			else:
				if !block_arrays.has(map.get_map()[y][x].type):
						block_arrays[map.get_map()[y][x].type] = {
						"cells" : [],
						"material" : mat_man.materials[map.get_map()[y][x].type]
					}
				block_arrays[map.get_map()[y][x].type].cells.append(Vector2(y, x))
	print("Arranging Cells Finished")
	meshes.append(mb.generate_object(block_arrays, true))
	meshes.append(mb.generate_floors_and_roofs(Vector2(map.get_map().size(), map.get_map()[0].size()), mat_man.materials[0]))
	print("Generate Meshes Finished")
	print("DROPING COULDRON")
	var tmp = EntityManager.get_couldron_scene().instantiate()
	var tmp_pos = map.couldron * MeshBuilder.tileSize
	tmp.global_position = Vector3(tmp_pos.x, 0, tmp_pos.y)
	entities.append(tmp)
	
func instanite_entities(cell, y, x):
	#print("Instantiate entities")
	if cell.entities:
		if cell.entities.size() > 0:
			for entity_id in cell.entities:
				var tmp = EntityManager.get_entity(entity_id).instantiate()
				var tmp_pos = Vector2(y, x) * MeshBuilder.tileSize
				tmp.global_position = Vector3(tmp_pos.x, 0.5, tmp_pos.y)
				entities.append(tmp)
				
	if cell.collectable != null:
		print("COLLECTABLE FOUND, ADDING TO CELL AT: " + str(Vector2(y, x)))
		var tmp = EntityManager.get_collectable(cell.collectable).instantiate()
		var tmp_pos = Vector2(y, x) * MeshBuilder.tileSize
		tmp.global_position = Vector3(tmp_pos.x, 0, tmp_pos.y)
		entities.append(tmp)
		
