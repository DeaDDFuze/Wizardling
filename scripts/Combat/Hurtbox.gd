
class_name Hurtbox
extends Area2D

signal hit_received(
	damage: int,
	knockback: Vector2
)

@export var knockback_multiplier: float = 1.0


func receive_hit(
	damage: int = 1,
	knockback: Vector2 = Vector2.ZERO
) -> void:

	var final_knockback := knockback * knockback_multiplier

	hit_received.emit(damage, final_knockback)

	print(
		owner.name,
		" reçoit ", damage,
		" dégât(s). Recul : ", final_knockback
	)
