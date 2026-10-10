
class_name State
extends Node


signal transition_requested(new_state: String)

@onready var player: WizardlingPlayer = owner as WizardlingPlayer
@onready var animated_sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")

func enter() -> void:
	pass

func exit() -> void:
	pass
	

func check_dash() -> bool:
	if Input.is_action_just_pressed("dash") and player.can_dash():
		transition_requested.emit("Dash")
		return true
	return false

	
func physics_update(_delta: float) -> void:
	pass
