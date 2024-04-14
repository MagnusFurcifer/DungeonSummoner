extends Node2D

const activate_sounds = [preload("res://ui_systems/assets/card_activate_sounds/0.wav"),
						preload("res://ui_systems/assets/card_activate_sounds/1.wav"),
						preload("res://ui_systems/assets/card_activate_sounds/2.wav"),
						preload("res://ui_systems/assets/card_activate_sounds/3.wav")]


@onready var anim = $AnimationPlayer
@onready var activate_emitter = $activate_particles
@onready var death_timer = $death_timer
@onready var card_sprite = $card_sprite

var hover_y_pos = -48
var hovered = false
var is_active = false
var pos = null

signal card_activated


var card_details = {
	"image" : null,
	"title" : "Fire Demon",
	"description" : "Summon a Flame",
	"damage_type" : 0,
	"card_type" : 0,
	"healing_value" : 5,
	"color" : Color.WHITE,
}

func activate():
	set_inactive()
	anim.play("activate")
	$card_control.visible = false
	$card_control.queue_free()
	
	if card_details.card_type == 0:
		if GameManager.player:
			var res = GameManager.player.is_entity_in_front_cell()
			print(res)
			if res:
				if res is Entity:
					res.hit(card_details.damage_type)
	else:
		if GameManager.player:
			GameManager.player.heal(card_details.healing_value)
	
func init(pos, delay, cards_manager, is_card_delay_active):
	if is_card_delay_active: 
		set_inactive()
	else:
		set_active()
	
	self.pos = pos
	$draw_delay.wait_time = 0.05 + delay
	anim.play("undrawn")
	cards_manager.on_card_delay_start.connect(_on_card_delay_start)
	cards_manager.on_card_delay_finish.connect(on_card_delay_finish)
	
	card_details = CardManager.get_random_card()
	#STUP THE CARD DETS
	if card_details.image:
		$card_sprite/card_image.texture = card_details.image
	$card_sprite/card_text/card_title.text = card_details.title
	$card_sprite/card_text/card_details.text = card_details.description
	
	
	
func _on_card_delay_start():
	set_inactive()
func on_card_delay_finish():
	set_active()
	
	
	
func set_active():
	is_active = true
	$card_sprite/disabled_rect.visible = false
		
func set_inactive():
	is_active = false
	$card_sprite/disabled_rect.visible = true
	
func _on_card_control_mouse_entered():
	print("MOUSE ENTERED ON CARD")
	hovered = true
	self.position.y = hover_y_pos
	self.z_index = 1
	
func _on_card_control_mouse_exited():
	print("MOUSE EXITED ON CARD")
	hovered = false
	self.position.y = 0
	self.z_index = 0


	
func _on_card_control_gui_input(event):
	if is_active:
		if event is InputEventMouseButton:
			if event.button_index == 1:
				if event.pressed:
					if hovered:
						emit_signal("card_activated", self)


func _on_animation_player_animation_finished(anim_name):
	print("animation_finioshed on card: " + str(anim_name))
	if anim_name == "activate":
		activate_emitter.process_material.color = card_details.color
		activate_emitter.emitting = true
		$activate_sound.stream = activate_sounds[randi() % activate_sounds.size()]
		$activate_sound.play()
		death_timer.start()
		card_sprite.visible = false
	elif anim_name == "undrawn":
		$draw_delay.start()
	elif anim_name == "draw":
		pass

func _on_death_timer_timeout():
	self.queue_free()


func _on_draw_delay_timeout():
	anim.play("draw")
	$draw_card.play()
