
extends State

@onready var hurt_timer: Timer = $HurtTimer


func _ready() -> void:
	hurt_timer.timeout.connect(on_hurt_finished)


func enter() -> void:
	player.movement_locked = false
	player.velocity.x = 0.0

	animated_sprite.play("Hurt")
	hurt_timer.start()


func physics_update(delta: float) -> void:
	player.apply_gravity(delta)
	player.velocity.x = 0.0


func exit() -> void:
	hurt_timer.stop()


func on_hurt_finished() -> void:
	if player.is_dead:
		return

	if not player.is_on_floor():
		if player.velocity.y < 0.0:
			transition_requested.emit("Jump")
		else:
			transition_requested.emit("Fall")
	elif player.get_direction() != 0.0:
		transition_requested.emit("Run")
	else:
		transition_requested.emit("Idle")
