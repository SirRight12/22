@tool
extends Node

signal mouse_update()

var mouse_position:Vector2 = Vector2(0,0):
	set = set_pos
func set_pos(value:Vector2):
	mouse_position = value
	mouse_update.emit(mouse_position)
