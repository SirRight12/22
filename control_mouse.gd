extends Node2D
var prev_pos = Vector2()
var going_left = false
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
func _process(_delta: float) -> void:
	prev_pos = global_position
	global_position = get_local_mouse_position()
	var direction = (global_position - prev_pos)
	if direction.x < 0:
		going_left = true
		self.rotation_degrees = -9.5
	elif direction.x > 0 :
		self.rotation_degrees = 9.5
	else:
		self.rotation_degrees = 0
		
