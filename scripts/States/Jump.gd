
extends State



func enter() -> void:
	# Ne déclencher une impulsion que depuis le sol
	if player.is_on_floor():
		player.velocity.y = WizardlingPlayer.JUMP_VELOCITY

	animated_sprite.play("Jumping")



func physics_update(_delta: float) -> void:
	
	player.apply_gravity(_delta)
	player.apply_horizontal_movement()
	player.update_facing()
	
	if check_dash():
		return
	if check_attack():
		return
	# Le personnage atteint le sommet du saut
	if player.velocity.y >= 0.0:
		transition_requested.emit("Fall")
