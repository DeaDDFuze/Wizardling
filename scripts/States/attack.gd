
extends State

enum AttackDirection {
	HORIZONTAL,
	UP,
	DOWN
}

var attack_direction: AttackDirection
var attack_animation: StringName


@onready var horizontal_hitbox: Hitbox = player.get_node("Hitboxes/Horizontal")
@onready var up_hitbox: Hitbox = player.get_node("Hitboxes/Up")
@onready var down_hitbox: Hitbox = player.get_node("Hitboxes/Down")

var current_hitbox: Hitbox


func select_hitbox() -> void:
	match attack_direction:
		AttackDirection.HORIZONTAL:
			current_hitbox = horizontal_hitbox

		AttackDirection.UP:
			current_hitbox = up_hitbox

		AttackDirection.DOWN:
			current_hitbox = down_hitbox


func update_hitbox() -> void:
	if current_hitbox == null:
		return

	# Frames 1, 2 et 3 = phase active du coup
	if animated_sprite.frame >= 1 and animated_sprite.frame <= 3:
		if not current_hitbox.active:
			current_hitbox.activate()
	else:
		current_hitbox.deactivate()


func disable_hitboxes() -> void:
	horizontal_hitbox.deactivate()
	up_hitbox.deactivate()
	down_hitbox.deactivate()


func enter() -> void:
	# Déterminer la direction de l'attaque
	if Input.is_action_pressed("up"):
		attack_direction = AttackDirection.UP
	elif Input.is_action_pressed("down") and not player.is_on_floor():
		attack_direction = AttackDirection.DOWN
	else:
		attack_direction = AttackDirection.HORIZONTAL

	disable_hitboxes()
	select_hitbox()
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
	
	animated_sprite.frame_changed.connect(update_hitbox)

	animated_sprite.play(attack_animation)
	
	update_hitbox()

	print("ATTACK : ", AttackDirection.keys()[attack_direction])


func physics_update(delta: float) -> void:
	# Conserver la gravité pendant les attaques
	player.apply_gravity(delta)

	# L'inertie horizontale est conservée,
	# mais aucune nouvelle accélération n'est appliquée.


func exit() -> void:
	
	disable_hitboxes()

	if animated_sprite.frame_changed.is_connected(update_hitbox):
		animated_sprite.frame_changed.disconnect(update_hitbox)
	if animated_sprite.animation_finished.is_connected(
		on_animation_finished
	):
		animated_sprite.animation_finished.disconnect(
			on_animation_finished
		)



func on_down_hit(_target: Hurtbox) -> void:
	if attack_direction != AttackDirection.DOWN:
		return

	# Le pogo ne s'applique que pendant la descente
	if player.velocity.y < 0.0:
		return

	player.velocity.y = WizardlingPlayer.POGO_VELOCITY
	print("POGO JUMP !")

func _ready() -> void:
	down_hitbox.target_hit.connect(on_down_hit)

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
