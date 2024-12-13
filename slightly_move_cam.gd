@tool
extends Node3D
@onready var camera = $Camera3D
var sens = .05
@export var max_neck_rotation:Vector3
@export var min_neck_rotation:Vector3
@export var max_camera_rotation:Vector3
@export var min_camera_rotation:Vector3
var move_speed = 200

func mouse_moved(mouse_pos):
	var size = get_viewport().size
	var percent_x = mouse_pos.x / size.x
	var percent_y = mouse_pos.y / size.y
	var new_rot = Vector3(max_neck_rotation)
	new_rot = new_rot.lerp(min_neck_rotation,percent_x)
	rotation_degrees = new_rot
func _ready() -> void:
	print('ready lol')
	MouseManager.mouse_update.connect(mouse_moved)
