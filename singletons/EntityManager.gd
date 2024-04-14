extends Node


var couldron_scene = preload("res://entities/couldron/couldron.tscn")

var entity_scenes = [
	preload("res://entities/flame_enemy/enemy.tscn"),
	preload("res://entities/water_enemy/enemy.tscn"),
]


var collectable_scenes = [
	preload("res://entities/collectable_tomato/collectable.tscn"),
	preload("res://entities/collectable_tongue/collectable.tscn"),
	preload("res://entities/collectable_bonedust/collectable.tscn"),
]

func get_random_entity():
	return entity_scenes[randi() % entity_scenes.size()]
	
func get_couldron_scene():
	return couldron_scene
	
func get_random_entity_id():
	return randi() % entity_scenes.size()
	
func get_entity(id):
	return entity_scenes[id]
	
	
func get_collectable(id):
	return collectable_scenes[id]
