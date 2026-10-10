
extends State


func enter() -> void:
	update_animation()
	print("Etat : RUN")


func physics_update(_delta: float) -> void:
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
