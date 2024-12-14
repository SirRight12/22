extends Node2D
var prev_pos = Vector2()
var going_left = false
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
func tween_stuff(obj:Object,property:NodePath,final,duration:float):
	var tween = create_tween()
	tween.tween_property(obj,property,final,duration)
	await tween.finished
	return
func _process(_delta: float) -> void:
	prev_pos = global_position
	global_position = get_global_mouse_position()
	MouseManager.mouse_position = get_global_mouse_position()
	var direction = (global_position - prev_pos)
	if direction.x < 0:
		going_left = true
		tween_stuff(self,'rotation_degrees',-1.5 * abs(direction.x),.1)
	elif direction.x > 0 :
		tween_stuff(self,'rotation_degrees',1.5 * abs(direction.x),.1)
	else:
		tween_stuff(self,'rotation_degrees',0,.4)
		
