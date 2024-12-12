extends Node3D
@onready var camera = $Camera3D
var sens = .05
var target_rot = Vector3(0,0,0)
var move_speed = 200
var target_cam_rot = Vector3(-37.1,0,0)
func _input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion:
		return
	
	target_cam_rot.x += -event.relative.y * sens
	target_cam_rot.x = clamp(target_cam_rot.x,-53.6,9.9)
	target_rot.y += -event.relative.x * sens
	target_rot.y = clamp(target_rot.y,-44.7,44.7)
	

func _process(delta: float) -> void:
	rotation_degrees = rotation_degrees.move_toward(target_rot,move_speed * delta)
	#rotation_degrees = target_rot
	
	camera.rotation_degrees = camera.rotation_degrees.move_toward(target_cam_rot,move_speed * delta)
	#camera.rotation_degrees = target_cam_rot
