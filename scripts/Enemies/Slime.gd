
class_name Slime
extends Enemy

enum SlimeState {
	IDLE,
	RUN,
	ATTACK,
	HURT,
	DEATH
}

@export_group("Statistiques")
@export var move_speed: float = 60.0
@export var chase_speed: float = 95.0
@export var attack_range: float = 65.0

@export_group("Combat")
@export var attack_cooldown: float = 1.8

# Numéros de frames, comptés à partir de 0.
@export_group("Synchronisation Attack")
@export var explosion_start_frame: int = 5
@export var explosion_end_frame: int = 7


var current_state: SlimeState = SlimeState.RUN
var facing: int = 1

var target: WizardlingPlayer = null
var cooldown: float = 0.0

var explosion_started: bool = false
var explosion_finished: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_hitbox: Hitbox = $ExplosionHitbox
@onready var detection: Area2D = $DetectionArea
@onready var ground_ray: RayCast2D = $GroundRay



func has_super_armor() -> bool:
	return current_state == SlimeState.ATTACK


func _ready() -> void:
	super._ready()

	explosion_hitbox.deactivate()

	detection.body_entered.connect(on_body_detected)
	detection.body_exited.connect(on_body_lost)

	sprite.frame_changed.connect(on_frame_changed)
	sprite.animation_finished.connect(on_animation_finished)

	change_state(SlimeState.RUN)




func _physics_process(delta: float) -> void:
	# Santé et invulnérabilité héritées de Enemy
	super._physics_process(delta)

	if is_dead:
		return

	# Gestion du délai entre les attaques
	cooldown = maxf(cooldown - delta, 0.0)

	# La gravité s'applique à tous les états vivants
	update_gravity(delta)

	# Intelligence artificielle du Slime
	match current_state:
		SlimeState.IDLE:
			update_idle()

		SlimeState.RUN:
			update_run()

		SlimeState.ATTACK:
			velocity.x = 0.0

		SlimeState.HURT:
			update_hurt(delta)

		SlimeState.DEATH:
			return

	# Appliquer la vitesse et les collisions physiques
	move_and_slide()



func update_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

func on_hurt() -> void:
	change_state(SlimeState.HURT)

func change_state(new_state: SlimeState) -> void:
	if current_state == SlimeState.DEATH:
		return

	current_state = new_state

	match current_state:
		SlimeState.IDLE:
			sprite.play("Idle")
			velocity.x = 0.0

		SlimeState.RUN:
			knockback_active = false
			sprite.play("Run")

		SlimeState.ATTACK:
			start_attack()

		SlimeState.HURT:
			sprite.play("Hurt")
			explosion_hitbox.deactivate()

		SlimeState.DEATH:
			pass


func update_idle() -> void:
	velocity.x = 0.0

	if target != null:
		change_state(SlimeState.RUN)



func update_run() -> void:
	var desired_direction: int = facing
	var speed: float = move_speed

	# 1. Choisir la direction souhaitée
	if is_instance_valid(target) and not target.is_dead:
		var distance_x: float = (
			target.global_position.x - global_position.x
		)

		if absf(distance_x) <= attack_range \
		and cooldown <= 0.0:
			change_state(SlimeState.ATTACK)
			return

		desired_direction = 1 if distance_x >= 0.0 else -1
		speed = chase_speed

	# 2. Vérifier le sol dans la direction souhaitée
	ground_ray.position.x = 20.0 * desired_direction
	ground_ray.force_raycast_update()

	# 3. Si cette direction mène dans le vide,
	# ne pas poursuivre le joueur.
	if is_on_floor() and not ground_ray.is_colliding():
		velocity.x = 0.0
		sprite.play("Idle")
		return

	# 4. Vérifier les murs
	if is_on_wall() and desired_direction == facing:
		desired_direction *= -1

	# 5. Appliquer la direction autorisée
	facing = desired_direction
	velocity.x = facing * speed

	sprite.flip_h = facing < 0
	sprite.play("Run")


func start_attack() -> void:
	velocity.x = 0.0
	cooldown = attack_cooldown

	explosion_started = false
	explosion_finished = false

	explosion_hitbox.deactivate()
	sprite.play("Attack")

	print("SLIME : compression")


func on_frame_changed() -> void:
	if current_state != SlimeState.ATTACK:
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
	if current_state == SlimeState.DEATH:
		queue_free()
		return

	if current_state == SlimeState.ATTACK:
		explosion_hitbox.deactivate()
		change_state(SlimeState.RUN)
		return

	if current_state == SlimeState.HURT:
		change_state(SlimeState.RUN)


func update_hurt(delta: float) -> void:
	update_knockback(delta)



func on_death() -> void:
	current_state = SlimeState.DEATH

	explosion_hitbox.deactivate()
	detection.set_deferred("monitoring", false)

	sprite.play("Death")
	print("SLIME : mort")






func on_body_detected(body: Node2D) -> void:
	if body is WizardlingPlayer:
		target = body as WizardlingPlayer


func on_body_lost(body: Node2D) -> void:
	if body == target:
		target = null
