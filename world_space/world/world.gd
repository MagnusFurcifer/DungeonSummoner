extends Node3D

var astar_grid = AStarGrid2D.new()
var dunGen = null

func _ready():
	GameManager.world = self

func create_world(dunGen):
	self.dunGen = dunGen
	for meshes in dunGen.meshes:
		for mesh in meshes:
			add_child(mesh)
			
	for entity in dunGen.entities:
		add_child(entity)
		
		
	var s_loc = dunGen.get_player_spawn() * MeshBuilder.tileSize
	$player_controller.global_position = Vector3(s_loc.x, 0, s_loc.y)
	
	load_astar()
	
func load_astar():
	astar_grid.region = Rect2i(0, 0, dunGen.MAP_SIZE, dunGen.MAP_SIZE)
	astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astar_grid.update()
	var map = dunGen.map.get_map()
	for x in map:
		for y in map[x]:
			if y.type in [DungeonGenerator.CELL_TYPES.BRICK_WALL]:
				astar_grid.set_point_solid(Vector2(x, y))
	
