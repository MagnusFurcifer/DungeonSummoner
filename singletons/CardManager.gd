extends Node


var cards = [
	{
		"image" : preload("res://assets/cards/flame_demon.png"),
		"title" : "Flame Demon",
		"description" : "Summon a Flame",
		"card_type" : 0,
		"damage_type" : 0,
		"color" : Color.RED
	},
	{
		"image" : preload("res://assets/cards/flame_demon.png"),
		"title" : "Flame Demon",
		"description" : "Summon a Flame",
		"card_type" : 0,
		"damage_type" : 0,
		"color" : Color.RED
	},
	{
		"image" : preload("res://assets/cards/water_demon.png"),
		"title" : "Water Demon",
		"description" : "Summon Water",
		"card_type" : 0,
		"damage_type" : 1,
		"color" : Color.BLUE
	},
	{
		"image" : preload("res://assets/cards/water_demon.png"),
		"title" : "Water Demon",
		"description" : "Summon Water",
		"card_type" : 0,
		"damage_type" : 1,
		"color" : Color.BLUE
	},
	{
		"image" : preload("res://assets/cards/fairy.png"),
		"title" : "Healing Fairy",
		"description" : "Summon the healing powers",
		"card_type" : 1,
		"healing_value" : 5,
		"color" : Color.GREEN
	}
]

func _ready():
	randomize()

func get_random_card():
	return cards[randi() % cards.size()]
