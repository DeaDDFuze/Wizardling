
class_name Slime
extends CharacterBody2D

enum State {
	IDLE,
	RUN,
	ATTACK,
	HURT,
	DEATH
}

@export_group("Statistiques")
@export_range(1, 20) var max_health: int = 1
@export var move_speed: float = 60.0
@export var chase_speed: float = 95.0
@export var attack_range: float = 65.0

@export_group("Combat")
@export var attack_cooldown: float = 1.8
@export var hurt_duration: float = 0.25

# Numéros de frames, comptés à partir de 0.
@export_group("Synchronisation Attack")
@export var explosion_start_frame: int = 5
@export var explosion_end_frame: int = 7

var health: int
var current_state: State = State.RUN
var facing: int = 1

var target: WizardlingPlayer = null
var cooldown: float = 0.0
var hurt_timer: float = 0.0

var explosion_started: bool = false
var explosion_finished: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var explosion_hitbox: Hitbox = $ExplosionHitbox
@onready var detection: Area2D = $DetectionArea
@onready var ground_ray: RayCast2D = $GroundRay


func _ready() -> void:
	health = max_health

	explosion_hitbox.deactivate()

	hurtbox.hit_received.connect(take_damage)
	detection.body_entered.connect(on_body_detected)
	detection.body_exited.connect(on_body_lost)

	sprite.frame_changed.connect(on_frame_changed)
	sprite.animation_finished.connect(on_animation_finished)

	change_state(State.RUN)


func _physics_process(delta: float) -> void:
	if current_state == State.DEATH:
		return

	cooldown = maxf(cooldown - delta, 0.0)

	if current_state != State.HURT:
		update_gravity(delta)

	match current_state:
		State.IDLE:
			update_idle()

		State.RUN:
			update_run()

		State.ATTACK:
			velocity.x = 0.0

		State.HURT:
			update_hurt(delta)

	move_and_slide()


func update_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta


func change_state(new_state: State) -> void:
	if current_state == State.DEATH:
		return

	current_state = new_state

	match current_state:
		State.IDLE:
			sprite.play("Idle")
			velocity.x = 0.0

		State.RUN:
			sprite.play("Run")

		State.ATTACK:
			start_attack()

		State.HURT:
			sprite.play("Hurt")
			hurt_timer = hurt_duration
			explosion_hitbox.deactivate()

		State.DEATH:
			pass


func update_idle() -> void:
	velocity.x = 0.0

	if target != null:
		change_state(State.RUN)


func update_run() -> void:
	# Détecteur de bord devant le Slime
	ground_ray.position.x = 20.0 * facing
	ground_ray.force_raycast_update()

	if is_on_floor() and not ground_ray.is_colliding():
		facing *= -1

	if is_on_wall():
		facing *= -1

	var speed := move_speed

	if is_instance_valid(target) and not target.is_dead:
		var distance := target.global_position.x - global_position.x

		if absf(distance) <= attack_range and cooldown <= 0.0:
			change_state(State.ATTACK)
			return

		# Poursuivre seulement si le sol continue.
		var target_facing := 1 if distance >= 0.0 else -1

		ground_ray.position.x = 20.0 * target_facing
		ground_ray.force_raycast_update()

		if not is_on_floor() or ground_ray.is_colliding():
			facing = target_facing
			speed = chase_speed

	velocity.x = facing * speed
	sprite.flip_h = facing < 0


func start_attack() -> void:
	velocity.x = 0.0
	cooldown = attack_cooldown

	explosion_started = false
	explosion_finished = false

	explosion_hitbox.deactivate()
	sprite.play("Attack")

	print("SLIME : compression")


func on_frame_changed() -> void:
	if current_state != State.ATTACK:
		return

	var frame := sprite.frame

	if frame >= explosion_start_frame and not explosion_started:
		explosion_started = true
		explosion_hitbox.activate()
		print("SLIME : EXPLOSION !")

	if frame >= explosion_end_frame and not explosion_finished:
		explosion_finished = true
		explosion_hitbox.deactivate()


func on_animation_finished() -> void:
	if current_state == State.DEATH:
		queue_free()
		return

	if current_state == State.ATTACK:
		explosion_hitbox.deactivate()
		change_state(State.RUN)
		return

	if current_state == State.HURT:
		change_state(State.RUN)


func update_hurt(delta: float) -> void:
	hurt_timer -= delta

	# Décélération progressive du recul
	velocity.x = move_toward(
		velocity.x,
		0.0,
		500.0 * delta
	)

	if hurt_timer <= 0.0:
		change_state(State.RUN)


func take_damage(
	damage: int,
	knockback: Vector2
) -> void:
	if current_state == State.DEATH:
		return

	health = maxi(health - damage, 0)

	print("SLIME : ", health, "/", max_health, " PV")

	if health <= 0:
		die()
		return

	velocity = knockback
	change_state(State.HURT)


func die() -> void:
	current_state = State.DEATH

	velocity = Vector2.ZERO
	explosion_hitbox.deactivate()

	# Empêcher de nouveaux coups sur le Slime mort
	hurtbox.set_deferred("monitorable", false)

	sprite.play("Death")
	print("SLIME : mort")


func on_body_detected(body: Node2D) -> void:
	if body is WizardlingPlayer:
		target = body as WizardlingPlayer


func on_body_lost(body: Node2D) -> void:
	if body == target:
		target = null
