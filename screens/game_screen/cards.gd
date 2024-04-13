extends Node2D

const card_scene = preload("res://ui_systems/card.tscn")

var currently_in_timeout = false

@onready var card_nodes = [
	$card_0,
	$card_1,
	$card_2
]

@onready var discard_pile = $discard


var active_cards = []

signal on_card_delay_start
signal on_card_delay_finish


# Called when the node enters the scene tree for the first time.
func activate():
	draw_card(0, 0.0)
	draw_card(1, .25)
	draw_card(2, .5)


func draw_card(pos, delay):
	print("DRAWING NEW CARD AT: " + str(pos))
	var tmp = card_scene.instantiate()
	var target_node = card_nodes[pos]
	if target_node:
		target_node.add_child(tmp)
		tmp.card_activated.connect(_on_card_activated)
		tmp.init(pos, delay, self, $card_use_delay.time_left != 0)
		
		
func _on_card_activated(card):
	var pos = card.pos
	card.activate()
	card.reparent(discard_pile)
	emit_signal("on_card_delay_start")
	$card_use_delay.start()
	print(card.pos)
	if pos in [0, 1, 2]:
		print("DRAWING NEW CARD")
		draw_card(pos, 0.0)
	else:
		print("No pos found")


func _on_card_use_delay_timeout():
	emit_signal("on_card_delay_finish")
