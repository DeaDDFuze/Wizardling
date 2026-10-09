class_name WizardlingPlayer
extends CharacterBody2D

# Déplacements
const WALK_SPEED = 250.0
const SPRINT_SPEED = 500.0

# Saut
const JUMP_VELOCITY = -500.0
const GRAVITY_MULTIPLIER = 1.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const JUMP_RELEASE_MULTIPLIER = 4.0

var speed: float = WALK_SPEED


# Lecture de la direction
func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")


# Gestion du mouvement horizontal
func apply_horizontal_movement() -> void:
	var direction := get_direction()

	if Input.is_action_pressed("dash"):
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	if direction != 0.0:
		velocity.x = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)


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


# Oriente le personnage
func update_facing() -> void:
	var direction := get_direction()
	var sprite := $AnimatedSprite2D as AnimatedSprite2D

	if direction < 0.0:
		sprite.flip_h = true
	elif direction > 0.0:
		sprite.flip_h = false
