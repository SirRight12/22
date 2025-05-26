extends Node3D
@onready var camera = $Camera3D
var sens = .05
@export var max_neck_rotation:Vector3
@export var min_neck_rotation:Vector3
@export var max_camera_rotation:Vector3
@export var min_camera_rotation:Vector3
var move_speed = 200
var target_cam_rotation = Vector3(0,0,0)
var target_rotation = Vector3(0,0,0)

func mouse_moved(mouse_pos):
	if not camera.current:
		return
	var size = Vector2(1152,684)
	var percent_x = mouse_pos.x / size.x
	percent_x = clamp(percent_x,0.0,1.0)
	var percent_y = mouse_pos.y / size.y
	percent_y = clamp(percent_y,0.0,1.0)
	var new_rot = Vector3(max_neck_rotation)
	new_rot = new_rot.lerp(min_neck_rotation,percent_x)
	#rotation_degrees = new_rot
	target_rotation = new_rot
	var new_cam_rot = Vector3(max_camera_rotation)
	new_cam_rot = new_cam_rot.lerp(min_camera_rotation,percent_y)
	#camera.rotation_degrees = new_cam_rot
	target_cam_rotation = new_cam_rot
	tween_stuff(camera,'rotation_degrees',target_cam_rotation,.5)
	tween_stuff(self,'rotation_degrees',target_rotation,.5)
func tween_stuff(obj:Object,property:NodePath,final,duration):
	var tween = create_tween()
	tween.tween_property(obj,property,final,duration)
	return tween
func _ready() -> void:
	print('ready lol')
	MouseManager.mouse_update.connect(mouse_moved)
#func _process(delta: float) -> void:
	#rotation_degrees = rotation_degrees.move_toward(target_rotation,move_speed*delta)
	#camera.rotation_degrees = camera.rotation_degrees.move_toward(target_cam_rotation,move_speed*delta)
