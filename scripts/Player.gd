class_name WizardlingPlayer
extends CharacterBody2D

# Déplacements
const MOVE_SPEED = 375.0
const DASH_SPEED = 1200.0
const DASH_DURATION = 0.18

# Saut
const JUMP_VELOCITY = -500.0
const GRAVITY_MULTIPLIER = 1.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const JUMP_RELEASE_MULTIPLIER = 4.0



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
