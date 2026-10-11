
class_name Hurtbox
extends Area2D

signal hit_received


func receive_hit() -> void:
	hit_received.emit()
	print(owner.name, " a reçu un coup !")
