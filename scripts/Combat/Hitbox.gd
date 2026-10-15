
class_name Hitbox
extends Area2D

signal target_hit(target: Hurtbox)

@export_range(1, 20) var damage: int = 1
@export var knockback: Vector2 = Vector2.ZERO

# Oriente le recul horizontal à l'opposé de la source.
@export var radial_horizontal: bool = false

# Pour les pics et les pièges persistants.
@export var repeat_damage: bool = false
@export_range(0.1, 5.0) var repeat_interval: float = 0.85

var active: bool = false
var targets_hit: Array[Hurtbox] = []
var next_hit_time: Dictionary = {}


func activate() -> void:
	targets_hit.clear()
	next_hit_time.clear()
	active = true


func deactivate() -> void:
	active = false



func calculate_knockback(target: Hurtbox) -> Vector2:
	var result := knockback

	if radial_horizontal:
		# Position du personnage qui frappe
		var attacker := owner as Node2D

		if attacker != null:
			var direction := signf(
				target.owner.global_position.x
				- attacker.global_position.x
			)

			if is_zero_approx(direction):
				direction = 1.0

			result.x = absf(knockback.x) * direction

	return result



func _physics_process(_delta: float) -> void:
	if not active:
		return

	var now := Time.get_ticks_msec() / 1000.0

	for area in get_overlapping_areas():
		if not area is Hurtbox:
			continue

		var hurtbox := area as Hurtbox

		# Ignorer ses propres zones de réception.
		if hurtbox.owner == owner:
			continue

		if repeat_damage:
			if now < next_hit_time.get(hurtbox, 0.0):
				continue
		else:
			if hurtbox in targets_hit:
				continue

		if not repeat_damage:
			targets_hit.append(hurtbox)

		next_hit_time[hurtbox] = now + repeat_interval

		var impulse := calculate_knockback(hurtbox)

		hurtbox.receive_hit(damage, impulse)
		target_hit.emit(hurtbox)
