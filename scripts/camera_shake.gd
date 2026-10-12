extends Camera2D

@export var shake_strength: float = 4.0
@export var shake_duration: float = 0.12

var shake_timer: float = 0.0
var shake_direction: Vector2 = Vector2.ZERO


func directional_shake(direction: Vector2) -> void:
	shake_direction = direction.normalized()
	shake_timer = shake_duration


func _process(delta: float) -> void:
	if shake_timer > 0.0:
		shake_timer = maxf(shake_timer - delta, 0.0)

		var intensity := shake_timer / shake_duration

		offset = shake_direction * shake_strength * intensity

	else:
		offset = Vector2.ZERO
