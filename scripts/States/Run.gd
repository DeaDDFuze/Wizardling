
extends State


func enter() -> void:
	update_animation()



func physics_update(_delta: float) -> void:
	
	player.apply_gravity(_delta)
	player.apply_horizontal_movement()
	player.update_facing()
	
	if check_dash():
		return
	if not player.is_on_floor():
		transition_requested.emit("Fall")
		return

	if Input.is_action_just_pressed("jump"):
		transition_requested.emit("Jump")
		return

	if player.get_direction() == 0.0:
		transition_requested.emit("Idle")
		return

	update_animation()


func update_animation() -> void:
		animated_sprite.play("Running")
