@tool
extends Node3D

@onready var sprite = $Sprite3D
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var alt_text:Label = $SubViewport/Label/Label/Label2
var is_owner = false
@export var value:int = 1:
	set = set_value
@export var hidden:bool = false:
	set = set_hidden
func set_hidden(val):
	hidden = val
	eval_hidden()
func eval_hidden():
	if not is_node_ready():
		await ready
	if hidden:
		sprite.texture = load("res://Cards/Back.tres")
		print('hiding')
		alt_text.text = '?'
	else:
		true_num()
		show_number_val()
	if is_owner:
		true_num()
func true_num():
	$Sprite3D2.show()
	alt_text.text = str(value)
func hidden_num():
	$Sprite3D2.show()
	if hidden:
		alt_text.text = '?'
		return
	alt_text.text = str(value)
func hide_num():
	$Sprite3D2.hide()
var file_start = 'res://Cards/'
var file_end = '.tres'
func set_value(val):
	if not is_node_ready():
		await ready
	value = val
	eval_hidden()
func show_number_val():
	sprite.texture = load(file_start + str(value) +  file_end)
func slide():
	if not is_node_ready():
		await ready
	animation_player.play('reveal')
	pass
