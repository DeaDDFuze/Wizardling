class_name WizardlingPlayer
extends CharacterBody2D


signal health_changed(current: int, maximum: int)
signal died

@export_range(1, 20) var max_health: int = 3

var health: int = 3
var is_dead: bool = false
var is_invulnerable: bool = false

@onready var state_machine: StateMachine = $StateMachine
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var invulnerability_timer: Timer = $InvulnerabilityTimer


# Déplacements
const MOVE_SPEED = 375.0
const DASH_SPEED = 1200.0
const DASH_DURATION = 0.18

# Saut
const JUMP_VELOCITY = -500.0
const GRAVITY_MULTIPLIER = 1.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const JUMP_RELEASE_MULTIPLIER = 4.0
const POGO_VELOCITY = -420.0

var movement_locked: bool = false


var facing_direction: int = 1
var air_dash_available: bool = true


@onready var dash_cooldown: Timer = $DashCooldown


# Lecture de la direction
func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")


# Gestion du mouvement horizontal

func apply_horizontal_movement() -> void:
	var direction := get_direction()

	if direction != 0.0:
		velocity.x = direction * MOVE_SPEED
	else:
		velocity.x = move_toward(
			velocity.x,
			0.0,
			MOVE_SPEED
		)



# Gestion de la gravité
func apply_gravity(delta: float) -> void:
	if is_on_floor():
		return

	var gravity := get_gravity().y

	if velocity.y < 0.0:
		if Input.is_action_pressed("jump"):
			velocity.y += gravity * GRAVITY_MULTIPLIER * delta
		else:
			velocity.y += gravity * JUMP_RELEASE_MULTIPLIER * delta
	else:
		velocity.y += gravity * FALL_GRAVITY_MULTIPLIER * delta
		

func can_dash() -> bool:
	return (
		dash_cooldown.is_stopped()
		and (is_on_floor() or air_dash_available)
	)



# Oriente le personnage
func update_facing() -> void:
	var direction := get_direction()
	var sprite := $AnimatedSprite2D as AnimatedSprite2D

	if direction < 0.0:
		facing_direction = -1
	elif direction > 0.0:
		facing_direction = 1
		
	sprite.flip_h = facing_direction < 0
	
	$Hitboxes/Horizontal.position.x = 38.0 * facing_direction
	

func _ready() -> void:
	health = max_health

	hurtbox.hit_received.connect(on_hurtbox_hit)
	invulnerability_timer.timeout.connect(
		end_invulnerability
	)

	health_changed.emit(health, max_health)


func on_hurtbox_hit() -> void:
	take_damage(1)


func take_damage(amount: int) -> void:
	if is_dead or is_invulnerable:
		return

	if amount <= 0:
		return

	health = maxi(health - amount, 0)
	health_changed.emit(health, max_health)

	print("PV : ", health, "/", max_health)

	if health == 0:
		die()
		return

	is_invulnerable = true
	invulnerability_timer.start()
	state_machine.change_state("Hurt")


func end_invulnerability() -> void:
	is_invulnerable = false


func die() -> void:
	if is_dead:
		return

	is_dead = true
	health = 0
	velocity = Vector2.ZERO

	health_changed.emit(health, max_health)
	died.emit()

	state_machine.change_state("Death")
