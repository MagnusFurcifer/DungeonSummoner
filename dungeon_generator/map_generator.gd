extends Node

class_name MapGenerator

var level = []
var rooms = []

const ROOM_MAX_SIZE = 4
const ROOM_MIN_SIZE = 2
const MAX_ROOMS = 6
const MIN_ROOMS = 4
const MAX_TRIES = 100
var num_rooms = 0

var min_entities = 5
var max_entities = 10
var max_entity_tries = 20


var spawn = Vector2(0, 0)
var couldron = Vector2(0, 0)

var entities = []

func get_map():
	return level
	
func get_rooms():
	return rooms

func _init():
	randomize()
	
	
func init_level(size, fill_tile_id):
	for y in range(0, size.y):
		var x_row = []
		for x in range(0, size.x):
			x_row.append(
				{ "type" : fill_tile_id, 
				"player_spawn" : false,
				"entities" : [],
				"collectable" : null})
		level.append(x_row)
		
	

func generate_level(size: Vector2):
	#print("Generate level called")
	init_level(size, DungeonGenerator.CELL_TYPES.BRICK_WALL)
	
	var tries = 0
	var success = false
	while tries < MAX_TRIES || !success:
		tries += 1
		generation_attempt(tries, size)
		if num_rooms < MIN_ROOMS:
			rooms = []
			num_rooms = 0
			level = []
			init_level(size, 0)
		else:
			success = true
			break
			
	cull_occluded_walls()
	
	#Set Spawn
	level[spawn.x][spawn.y]['player_spawn'] = true 
	
	print(rooms)
	
	populate_entities(size)
	
	populate_collectables()
	
	
	
	
func populate_collectables():
	print("populate_collectables in room: " + str(rooms[1]))
	add_collectable_to_room(rooms[1], 0)
	add_collectable_to_room(rooms[2], 1)
	add_collectable_to_room(rooms[3], 2)
	
	
	
func add_collectable_to_room(room, id):
	var x = room['x'] + (randi() % room['w'])
	var y = room['y']  + (randi() % room['h'])
	print("Adding collectable to: " + str(Vector2(y, x)))
	var tmp = level[x][y]
	tmp.collectable = id
	tmp.type = DungeonGenerator.CELL_TYPES.BLANK_ROOM
	tmp.entities = []
	level[x][y] = tmp
	
func populate_entities(size):
	var num = randi_range(min_entities, max_entities)
	for i in num:
		var tries = 0
		var success = false
		while tries < max_entity_tries && !success:
			var rand_x = randi() % int(size.x)
			var rand_y = randi() % int(size.y)
			if level[rand_x][rand_y].type == DungeonGenerator.CELL_TYPES.BLANK_HALL || level[rand_x][rand_y].type == DungeonGenerator.CELL_TYPES.BLANK_ROOM:
				level[rand_x][rand_y].entities.append(EntityManager.get_random_entity_id())
				success = true
			tries += 1
	
	
func cull_occluded_walls():
	for x in range(0, level.size()-1):
		for y in range(0, level[0].size()-1):
			var tmp_wall = DungeonGenerator.CELL_TYPES.BRICK_WALL
			if level[x][y]['type'] == tmp_wall:
				if ((level[x - 1][y]['type'] == tmp_wall) && 
					(level[x + 1][y]['type'] == tmp_wall) && 
					(level[x][y-1]['type'] == tmp_wall) &&
					(level[x][y+1]['type'] == tmp_wall)):
						level[x][y] = { "type" : DungeonGenerator.CELL_TYPES.BLANK, 
						'entities' : [] ,  'player_spawn' : false,
						"collectable" : null}
	

func generation_attempt(tries, size):
	var target_room_num = randi() % MAX_ROOMS + MIN_ROOMS
	for r in target_room_num:
		var tmp_w = ROOM_MIN_SIZE + randi() % (ROOM_MAX_SIZE - ROOM_MIN_SIZE)
		var tmp_h = ROOM_MIN_SIZE + randi() % (ROOM_MAX_SIZE - ROOM_MIN_SIZE)
		var room_def = {
			'w' : tmp_w,
			'h' : tmp_h,
			'x' : clamp(randi() % int((size.x - (tmp_w + 1)) + 1), 1, size.x - (tmp_w + 2)),
			'y' : clamp(randi() % int((size.y - (tmp_h + 1)) + 1), 1, size.y - (tmp_h + 2)),
		}
			
		var failed = false
		for other_room in rooms:
			if room_intersects(room_def, other_room):
				failed = true
				
		if room_def['x'] < 0 || room_def['x'] + room_def['w'] >= size.x:
			failed = true
		if room_def['y'] < 0 || room_def['y'] + room_def['h'] >= size.y:
			failed = true
				
		if !failed:
			var new_x = room_def['x'] + floor( room_def['w'] / 2 )
			var new_y = room_def['y'] + floor( room_def['h'] / 2 )
			
			if num_rooms == 0:
				create_room(room_def, 0)
				spawn.x = room_def['x'] + floor( room_def['w'] / 2 )
				spawn.y = room_def['y'] + floor( room_def['h'] / 2 )
				couldron.x = room_def['x'] + floor(room_def['w'] / 2 - 1)
				couldron.y = room_def['y'] + floor(room_def['h'] / 2 - 1)
				
				
			else:
				create_room(room_def, 1)
				var prev_x = rooms[num_rooms-1]['x'] + floor( rooms[num_rooms-1]['w'] / 2 )
				var prev_y = rooms[num_rooms-1]['y'] + floor( rooms[num_rooms-1]['h'] / 2 )
				if randi() % 2:
					createHorTunnel(prev_x, new_x, prev_y);
					createVirTunnel(prev_y, new_y, new_x);
				else:
					createVirTunnel(prev_y, new_y, prev_x);
					createHorTunnel(prev_x, new_x, new_y);
				
			rooms.append(room_def)
			num_rooms += 1
			
			
func create_room(room, type):
	for x in range(room['x'], room['x'] + room['w']):
		for y in range(room['y'], room['y'] + room['h']):
			level[x][y] = { "type" : DungeonGenerator.CELL_TYPES.BLANK_ROOM, 
								'entities' : [] , 
								'player_spawn' : false,
								"collectable" : null}
			
	
					

func room_intersects(room1, room2):
	if (room1['x'] >= (room2['x'] + room2['w']) || room2['x'] >= (room1['x'] + room1['w'])): return false
	if (room1['y'] >= (room2['y'] + room2['h']) || room2['y'] >= (room1['y'] + room1['h'])): return false
	return true;


func createHorTunnel(x1, x2, z):
	var xmin = floor(min(x1, x2))
	var xmax = floor(max(x1, x2) + 1)
	for x in range(xmin, xmax): 
		level[x][z] = { "type" : DungeonGenerator.CELL_TYPES.BLANK_HALL, 
								'entities' : [] , 
								'player_spawn' : false,
								"collectable" : null}
func createVirTunnel(z1, z2, x):
	var zmin = floor(min(z1, z2))
	var zmax = floor(max(z1, z2) + 1)
	for z in range(zmin, zmax): 
		level[x][z] = { "type" : DungeonGenerator.CELL_TYPES.BLANK_HALL, 
								'entities' : [] , 
								'player_spawn' : false,
								"collectable" : null}
