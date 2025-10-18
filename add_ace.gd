@tool
extends Node3D
##Class, so I can get the function when referencing the node lol
class_name AceTable
@export var test_ace_name:String = 'None'
@export_tool_button('Test Ace') var thing = test_ace

@onready var ace_scene = load("res://ace.tscn")
func test_ace():
	add_ace(test_ace_name)
func add_ace(ace_name):
	var file = load('res://table_aces/' + str(ace_name) + '.png')
	if not file:
		file = load('res://table_aces/Ace.png')
	var new_ace:Node3D = ace_scene.instantiate()
	self.add_child(new_ace)
	new_ace.position += Vector3(-0.08 * (get_child_count() - 1),0,0)
	new_ace.sprite.texture = file
	new_ace.sprite.modulate = Color(Color.WHITE,0.0)
	new_ace.sprite.scale = Vector3.ZERO
	new_ace.sprite.position = Vector3(0,1,0)
	var tween = create_tween().tween_property(new_ace.sprite,'modulate',Color.WHITE,.4)
	create_tween().tween_property(new_ace.sprite,'position',Vector3.ZERO,.4)
	create_tween().tween_property(new_ace.sprite,'scale',Vector3.ONE,.4)
func clear_aces():
	for child in get_children():
		remove_child(child)
func remove_top():
	var ace = get_children().pop_back()
	if not ace:
		return
	ace.sprite.position.y = 0
	ace.sprite.scale = Vector3.ONE
	ace.sprite.modulate = Color.WHITE
	var tween = create_tween().tween_property(ace.sprite,'modulate',Color(Color.WHITE,0.0),.4)
	create_tween().tween_property(ace.sprite,'position',Vector3(0,1,0),.4)
	create_tween().tween_property(ace.sprite,'scale',Vector3.ZERO,.4)
	await tween.finished
	remove_child(ace)
