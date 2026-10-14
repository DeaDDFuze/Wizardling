
class_name Enemy
extends CharacterBody2D

signal health_changed(current: int, maximum: int)
signal died

@export_group("Santé")
@export_range(1, 200) var max_health: int = 1

@export_group("Knockback")
@export_range(0.0, 3.0) var knockback_multiplier: float = 1.0
@export var knockback_friction: float = 500.0

@export_group("Protection")
@export_range(0.0, 2.0) var invulnerability_duration: float = 0.15

var health: int
var is_dead: bool = false
var is_invulnerable: bool = false
var knockback_active: bool = false

var invulnerability_remaining: float = 0.0

@onready var hurtbox: Hurtbox = $Hurtbox


func _ready() -> void:
	health = max_health

	hurtbox.hit_received.connect(receive_hit)
	health_changed.emit(health, max_health)


func _physics_process(delta: float) -> void:
	if is_dead:
		return

	invulnerability_remaining = maxf(
		invulnerability_remaining - delta,
		0.0
	)

	if is_invulnerable and invulnerability_remaining <= 0.0:
		is_invulnerable = false


func receive_hit(
	damage: int,
	knockback: Vector2
) -> void:
	if is_dead or is_invulnerable or damage <= 0:
		return

	health = maxi(health - damage, 0)
	health_changed.emit(health, max_health)

	print(name, " : ", health, "/", max_health, " PV")

	if health <= 0:
		die()
		return

	is_invulnerable = true
	invulnerability_remaining = invulnerability_duration

	# Une attaque engagée conserve son mouvement.
	if has_super_armor():
		return

	velocity = knockback * knockback_multiplier
	knockback_active = true

	on_hurt()


func has_super_armor() -> bool:
	return false


func on_hurt() -> void:
	# À spécialiser pour chaque ennemi.
	pass


func update_knockback(delta: float) -> void:
	if not knockback_active:
		return

	velocity.x = move_toward(
		velocity.x,
		0.0,
		knockback_friction * delta
	)


func die() -> void:
	if is_dead:
		return

	is_dead = true
	velocity = Vector2.ZERO
	knockback_active = false

	# Désactiver immédiatement la collision physique
	var physical_collision := get_node_or_null(
        "CollisionShape2D"
	) as CollisionShape2D

	if physical_collision:
		physical_collision.set_deferred("disabled", true)

	# Empêcher les coups sur un ennemi mort
	hurtbox.set_deferred("monitorable", false)
	
	
	# Désactiver la zone de réception des coups
	var hurt_collision := hurtbox.get_node_or_null(
        "CollisionShape2D"
	) as CollisionShape2D

	if hurt_collision:
		hurt_collision.set_deferred("disabled", true)

	# Désactiver les zones offensives et leurs collisions
	for child in get_children():
		if child is Hitbox:
			child.deactivate()

			for hitbox_child in child.get_children():
				if hitbox_child is CollisionShape2D:
					hitbox_child.set_deferred("disabled", true)


	for child in get_children():
		if child is Hitbox:
			child.deactivate()

	died.emit()
	on_death()


func on_death() -> void:
	# Animation à gérer dans chaque espèce.
	pass
