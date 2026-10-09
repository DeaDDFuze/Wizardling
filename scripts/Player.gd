
extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

# Déplacements
const WALK_SPEED = 250.0
const SPRINT_SPEED = 500.0

# Saut
const JUMP_VELOCITY = -500.0
const GRAVITY_MULTIPLIER = 1.0
const FALL_GRAVITY_MULTIPLIER = 1.5
const JUMP_RELEASE_MULTIPLIER = 4.0

var speed = WALK_SPEED


func _physics_process(delta: float) -> void:
	# Gestion du saut
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Gestion de la gravité
	if not is_on_floor():
		var gravity = get_gravity().y

		if velocity.y < 0:
			# Le personnage monte
			if Input.is_action_pressed("jump"):
				velocity.y += gravity * GRAVITY_MULTIPLIER * delta
			else:
				# Saut relâché : freinage vertical rapide
				velocity.y += gravity * JUMP_RELEASE_MULTIPLIER * delta
		else:
			# Le personnage descend
			velocity.y += gravity * FALL_GRAVITY_MULTIPLIER * delta

	# Déplacement horizontal
	var direction := Input.get_axis("move_left", "move_right")
	var is_sprinting := Input.is_action_pressed("dash")

	if is_sprinting:
		speed = SPRINT_SPEED
	else:
		speed = WALK_SPEED

	if direction:
		velocity.x = direction * speed

		if direction < 0:
			animated_sprite.flip_h = true
		else:
			animated_sprite.flip_h = false
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	move_and_slide()

	# Animations : priorité au saut
	if not is_on_floor():
		if animated_sprite.animation != "Jumping":
			animated_sprite.play("Jumping")
	elif direction != 0:
		if is_sprinting:
			animated_sprite.play("Running")
		else:
			animated_sprite.play("Walking")
	else:
		animated_sprite.play("Idle")
