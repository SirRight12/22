@tool
extends Control
#
signal enter()
signal exit()
var aces = []
func _ready():
	pass
@export_tool_button('test_open') var openthing = tween_open
@export_tool_button('test_close') var close_thing = tween_close
@export_tool_button('test_aces') var ace_thing = _ready
func reset_children():
	for child in $GridContainer.get_children():
		var placeholder = Control.new()
		placeholder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		placeholder.size_flags_vertical = Control.SIZE_EXPAND_FILL
		placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
		for child2 in child.get_children():
			child.remove_child(child2)
		child.replace_by(placeholder)
func got_aces(list):
	reset_children()
	var i = 0
	var children = $GridContainer.get_children()
	for ace in list:
		print(ace)
		var child:Control = children[i]
		var ace_inst:Control = ace_scene.instantiate()
		ace_inst.set_ace_name(ace)
		child.replace_by(ace_inst)
		i += 1
	pass
@onready var ace_scene = load("res://ace_ui.tscn")
var is_open = false
var opening = false
var is_close = true
var closing = false
func open():
	is_close = false
	opening = true
	
	await tween_open()
	opening = false
	is_open = true
func close():
	is_open = false
	closing = true
	await tween_close()
	is_close = true
	closing = false
	pass
func tween_open():
	create_tween().tween_property(self,'anchor_left',.705,.4)
	create_tween().tween_property(self,'anchor_right',.99,.4)
func tween_close():
	create_tween().tween_property(self,'anchor_left',1.0,.4)
	create_tween().tween_property(self,'anchor_right',1.285,.4)
func ace_hovered(ace):
	print(ace)
	enter.emit()


func _on_color_rect_mouse_entered() -> void:
	print('entered')
	enter.emit()


func _on_color_rect_mouse_exited() -> void:
	exit.emit()
