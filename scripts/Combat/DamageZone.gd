
extends Area2D

@export_range(1, 20) var damage: int = 1


func _ready() -> void:
	body_entered.connect(on_body_entered)


func on_body_entered(body: Node2D) -> void:
	if body is WizardlingPlayer:
		body.take_damage(damage)
