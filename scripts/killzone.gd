
extends Area2D

@onready var timer: Timer = $Timer

var player_dead: bool = false


func _on_body_entered(body: Node2D) -> void:
	if player_dead:
		return

	if not body is WizardlingPlayer:
		return

	player_dead = true
	print("You Died !")

	# Arrêter la State Machine
	var state_machine: StateMachine = body.get_node("StateMachine")
	state_machine.set_physics_process(false)

	# Immobiliser le joueur
	body.velocity = Vector2.ZERO

	# Jouer provisoirement l'animation de mort
	var sprite: AnimatedSprite2D = body.get_node("AnimatedSprite2D")
	sprite.play("Death")

	# Démarrer le compte à rebours
	timer.start()


func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
