extends State


var dash_timer: float = 0.0
var dash_direction: int = 1


func enter() -> void:
	dash_timer = WizardlingPlayer.DASH_DURATION
	
	animated_sprite.play("")

	# Récupérer la direction mémorisée
	dash_direction = player.facing_direction

	# Consommer le Dash aérien si nécessaire
	if not player.is_on_floor():
		player.air_dash_available = false

	# Démarrer le cooldown
	player.dash_cooldown.start()

	# Appliquer immédiatement l'impulsion
	player.velocity = Vector2(
		dash_direction * WizardlingPlayer.DASH_SPEED,
		0.0
	)




func physics_update(delta: float) -> void:
	dash_timer -= delta

	# Maintenir une vitesse constante
	player.velocity.x = (
		dash_direction * WizardlingPlayer.DASH_SPEED
	)
	player.velocity.y = 0.0

	if dash_timer <= 0.0:
		if player.is_on_floor():
			if player.get_direction() != 0.0:
				transition_requested.emit("Run")
			else:
				transition_requested.emit("Idle")
		else:
			transition_requested.emit("Fall")


func exit() -> void:
	player.velocity.x = 0.0
