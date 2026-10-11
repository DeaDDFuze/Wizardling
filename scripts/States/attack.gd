
extends State

enum AttackDirection {
	HORIZONTAL,
	UP,
	DOWN
}

var attack_direction: AttackDirection
var attack_animation: StringName


func enter() -> void:
	# Déterminer la direction de l'attaque
	if Input.is_action_pressed("up"):
		attack_direction = AttackDirection.UP
	elif Input.is_action_pressed("down") and not player.is_on_floor():
		attack_direction = AttackDirection.DOWN
	else:
		attack_direction = AttackDirection.HORIZONTAL

	# Sélectionner l'animation
	match attack_direction:
		AttackDirection.HORIZONTAL:
			attack_animation = &"AttackHorizontal"
		AttackDirection.UP:
			attack_animation = &"AttackUp"
		AttackDirection.DOWN:
			attack_animation = &"AttackDown"

	# Écouter la fin de l'animation
	animated_sprite.animation_finished.connect(
		on_animation_finished
	)

	animated_sprite.play(attack_animation)

	print("ATTACK : ", AttackDirection.keys()[attack_direction])


func physics_update(delta: float) -> void:
	# Conserver la gravité pendant les attaques
	player.apply_gravity(delta)

	# L'inertie horizontale est conservée,
	# mais aucune nouvelle accélération n'est appliquée.


func exit() -> void:
	if animated_sprite.animation_finished.is_connected(
		on_animation_finished
	):
		animated_sprite.animation_finished.disconnect(
			on_animation_finished
		)


func on_animation_finished() -> void:
	if animated_sprite.animation != attack_animation:
		return

	# Retour à l'état de déplacement approprié
	if not player.is_on_floor():
		if player.velocity.y < 0.0:
			transition_requested.emit("Jump")
		else:
			transition_requested.emit("Fall")
	elif player.get_direction() != 0.0:
		transition_requested.emit("Run")
	else:
		transition_requested.emit("Idle")
