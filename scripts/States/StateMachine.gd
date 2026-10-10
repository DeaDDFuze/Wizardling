
class_name StateMachine
extends Node

@export var initial_state: State

@onready var player: WizardlingPlayer = owner as WizardlingPlayer

var current_state: State


func _ready() -> void:
	for child in get_children():
		if child is State:
			child.transition_requested.connect(change_state)

	if initial_state != null:
		current_state = initial_state
		current_state.enter()



func _physics_process(delta: float) -> void:
	
	player.apply_gravity(delta)
	player.apply_horizontal_movement()
	player.update_facing()

	if current_state == null:
		return

	# Mise à jour de l'état actif
	current_state.physics_update(delta)

	# Déplacement physique
	player.move_and_slide()

	# Recharge du Dash aérien au contact du sol
	if player.is_on_floor():
		player.air_dash_available = true



func change_state(new_state: String) -> void:
	var next_state := get_node_or_null(new_state) as State

	if next_state == null:
		push_warning("Etat introuvable : " + new_state)
		return

	if next_state == current_state:
		return

	if current_state != null:
		current_state.exit()

	current_state = next_state
	current_state.enter()
