extends Enemy




func hit(dmg_type):
	super(dmg_type)
	if current_state in [STATES.IDLE, STATES.ACTING]:
		var dmg = 1
		if dmg_type == 1:
			dmg = 5
		else:
			dmg = 1
			
		current_hp -= dmg
		show_damage(dmg)
