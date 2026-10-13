
extends State

enum AttackDirection {
	HORIZONTAL,
	UP,
	DOWN
}




var attack_direction: AttackDirection
var attack_animation: StringName

var attack_facing: int = 1

const HITSTOP_DURATION: float = 0.5

var hitstop_timer: float = 0.0
var hitstop_active: bool = false


@onready var horizontal_hitbox: Hitbox = player.get_node("Hitboxes/Horizontal")
@onready var up_hitbox: Hitbox = player.get_node("Hitboxes/Up")
@onready var down_hitbox: Hitbox = player.get_node("Hitboxes/Down")
@onready var camera: Camera2D = player.get_node("Camera2D")

var current_hitbox: Hitbox
var shake_triggered: bool = false


func select_hitbox() -> void:
	match attack_direction:
		AttackDirection.HORIZONTAL:
			current_hitbox = horizontal_hitbox

		AttackDirection.UP:
			current_hitbox = up_hitbox

		AttackDirection.DOWN:
			current_hitbox = down_hitbox


func start_hitstop() -> void:
	if hitstop_active:
		return

	hitstop_active = true
	hitstop_timer = 0.1
	player.movement_locked = true




func update_hitstop(delta: float) -> void:
	if not hitstop_active:
		return

	hitstop_timer -= delta

	if hitstop_timer <= 0.0:
		hitstop_active = false
		player.movement_locked = false


func trigger_attack_shake() -> void:
	if shake_triggered:
		return

	shake_triggered = true

	var direction := Vector2.ZERO

	match attack_direction:
		AttackDirection.HORIZONTAL:
			direction = Vector2(attack_facing, 0)

		AttackDirection.UP:
			direction = Vector2.UP

		AttackDirection.DOWN:
			direction = Vector2.DOWN

	camera.directional_shake(direction)

func update_hitbox() -> void:
	if current_hitbox == null:
		return

	if animated_sprite.frame >= 1 and animated_sprite.frame <= 3:
		if not current_hitbox.active:
			current_hitbox.activate()
			trigger_attack_shake()
	else:
		current_hitbox.deactivate()


func disable_hitboxes() -> void:
	horizontal_hitbox.deactivate()
	up_hitbox.deactivate()
	down_hitbox.deactivate()


func enter() -> void:
	
	hitstop_active = false
	hitstop_timer = 0.0
	
	shake_triggered = false
	
	attack_facing = player.facing_direction

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
	if hitstop_active:
		update_hitstop(delta)
		return

	player.apply_gravity(delta)

	var direction := player.get_direction()

	player.velocity.x = direction * WizardlingPlayer.MOVE_SPEED

	player.facing_direction = attack_facing
	animated_sprite.flip_h = attack_facing < 0
	horizontal_hitbox.position.x = 38.0 * attack_facing


func on_attack_hit(target: Hurtbox) -> void:
	start_hitstop()

func exit() -> void:
	
	player.movement_locked = false
	hitstop_active = false
	hitstop_timer = 0.0
	animated_sprite.play()
	
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

	if player.velocity.y < 0.0:
		return

	# Impulsion identique au saut normal
	player.velocity.y = WizardlingPlayer.JUMP_VELOCITY

	# Ignore le relâchement d'Espace durant la montée
	player.pogo_active = true

	print("POGO BOUNCE MAX !")


func _ready() -> void:
	horizontal_hitbox.target_hit.connect(on_attack_hit)
	up_hitbox.target_hit.connect(on_attack_hit)
	down_hitbox.target_hit.connect(on_attack_hit)

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
