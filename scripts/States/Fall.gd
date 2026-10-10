
extends State


func enter() -> void:
	animated_sprite.play("Jumping")



func physics_update(_delta: float) -> void:
	if check_dash():
		return
	if player.is_on_floor():
		if player.get_direction() != 0.0:
			transition_requested.emit("Run")
		else:
			transition_requested.emit("Idle")
