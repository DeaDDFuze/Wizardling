
extends Node2D

@onready var hitbox: Hitbox = $Hitbox


func _ready() -> void:
	hitbox.activate()
