extends Sprite2D
@onready var camera: Camera2D = $"../Player/Camera2D"



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = camera.get_screen_center_position()[0] * 0.5
	position.y = camera.get_screen_center_position()[1] * 0.25
