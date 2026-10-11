extends PointLight2D

@export var base_energy: float = 0.45
@export var pulse_amplitude: float = 0.08
@export var pulse_speed: float = 2.5

var time: float = 0.0

func _process(delta: float) -> void:
	time += delta

	energy = base_energy + sin(time * pulse_speed) * pulse_amplitude
