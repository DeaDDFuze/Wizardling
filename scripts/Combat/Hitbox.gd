
class_name Hitbox
extends Area2D

signal target_hit(target: Hurtbox)

var active: bool = false
var targets_hit: Array[Hurtbox] = []


func activate() -> void:
	targets_hit.clear()
	active = true


func deactivate() -> void:
	active = false


func _physics_process(_delta: float) -> void:
	if not active:
		return

	for area in get_overlapping_areas():
		if not area is Hurtbox:
			continue

		var hurtbox := area as Hurtbox

		# Ne pas se toucher soi-même
		if hurtbox.owner == owner:
			continue

		# Une cible ne reçoit qu'un coup par activation
		if hurtbox in targets_hit:
			continue

		targets_hit.append(hurtbox)
		hurtbox.receive_hit()
		target_hit.emit(hurtbox)
