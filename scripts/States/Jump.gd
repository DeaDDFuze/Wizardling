
extends State


func enter() -> void:
	player.velocity.y = WizardlingPlayer.JUMP_VELOCITY
	animated_sprite.play("Jumping")
	print("Etat : JUMP")


func physics_update(_delta: float) -> void:
	# Le personnage atteint le sommet du saut
	if player.velocity.y >= 0.0:
		transition_requested.emit("Fall")
