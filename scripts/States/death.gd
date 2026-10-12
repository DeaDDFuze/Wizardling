extends State


func enter() -> void:
	# Immobilisation définitive
	player.movement_locked = true
	player.velocity = Vector2.ZERO

	# Écouter la fin de l'animation
	if not animated_sprite.animation_finished.is_connected(
		on_death_finished
	):
		animated_sprite.animation_finished.connect(
			on_death_finished
		)

	animated_sprite.play("Death")


func physics_update(_delta: float) -> void:
	player.velocity = Vector2.ZERO


func exit() -> void:
	if animated_sprite.animation_finished.is_connected(
		on_death_finished
	):
		animated_sprite.animation_finished.disconnect(
			on_death_finished
		)


func on_death_finished() -> void:
	if animated_sprite.animation != &"Death":
		return

	get_tree().call_deferred("reload_current_scene")
