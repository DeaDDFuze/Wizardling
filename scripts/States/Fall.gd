
extends State


func enter() -> void:
	animated_sprite.play("Falling")



func physics_update(_delta: float) -> void:
	
	player.apply_gravity(_delta)
	player.apply_horizontal_movement()
	player.update_facing()
	
	if check_dash():
		return
	if player.is_on_floor():
		if player.get_direction() != 0.0:
			transition_requested.emit("Run")
		else:
			transition_requested.emit("Idle")
