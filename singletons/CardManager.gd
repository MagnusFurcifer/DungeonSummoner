extends Node


var cards = [
	{
		"image" : preload("res://assets/cards/flame_demon.png"),
		"title" : "Flame Demon",
		"description" : "Summon a Flame"
	},
	{
		"image" : preload("res://assets/cards/water_demon.png"),
		"title" : "Water Demon",
		"description" : "Summon Water"
	},
	{
		"image" : preload("res://assets/cards/fairy.png"),
		"title" : "Healing Fairy",
		"description" : "Summon the healing powers"
	}
]

func _ready():
	randomize()

func get_random_card():
	return cards[randi() % cards.size()]
