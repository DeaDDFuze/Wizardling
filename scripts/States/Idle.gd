extends State

func enter() -> void:
	animated_sprite.play("Idle")
	print("Etat : IDLE")


func physics_update(_delta: float) -> void:
	if not player.is_on_floor():
		transition_requested.emit("Fall")
		return

	if Input.is_action_just_pressed("jump"):
		transition_requested.emit("Jump")
		return

	if player.get_direction() != 0.0:
		transition_requested.emit("Run")
