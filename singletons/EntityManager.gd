extends Node


var entity_scenes = [
	preload("res://entities/flame_enemy/enemy.tscn"),
	preload("res://entities/flame_enemy/enemy.tscn"),
	preload("res://entities/flame_enemy/enemy.tscn"),
]


func get_random_entity():
	return entity_scenes[randi() % entity_scenes.size()]
	
	
func get_random_entity_id():
	return randi() % entity_scenes.size()
	
func get_entity(id):
	return entity_scenes[id]
