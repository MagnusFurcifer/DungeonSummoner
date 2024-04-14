extends Control

@onready var tilemap = $TileMap

var dunGen = null

func _ready():
	GameManager.minimap = self

func setup(dunGen):
	self.dunGen = dunGen
	init_tilemap()
	
	if GameManager.player:
		GameManager.player.updated_visited_tiles.connect(_on_player_visited_tile)
		
		
func remove_collectable(map_pos):
	tilemap.erase_cell(2, map_pos)
		

func init_tilemap():
	for y in dunGen.map.get_map().size():
		for x in dunGen.map.get_map()[y].size():
			tilemap.set_cell(0, Vector2(y, x), 1, Vector2(0, 0))
			
func _on_player_visited_tile(map_pos):
	print("PLAYER VISITED TILE: " + str(map_pos))
	tilemap.set_cell(0, map_pos, 1, Vector2(1, 0))
			
func player_seen_collectable(map_pos):
	print("PLAYER SEEN COLLECTABLE WHATTTT: " + str(map_pos))
	tilemap.set_cell(2, map_pos, 1, Vector2(3, 0))
			
func _physics_process(delta):
	if GameManager.player:
		tilemap.clear_layer(1)
		var map_pos = GameManager.player.get_current_tile()
		tilemap.set_cell(1, map_pos, 1, Vector2(2, 0))
