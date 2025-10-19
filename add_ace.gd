@tool
extends Node3D
##Class, so I can get the function when referencing the node lol
class_name AceTable
@export var test_ace_name:String = 'None'
@export_tool_button('Test Reformat') var thing = draw_ace

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
func remove_at(idx:int):
	var trumps = self.get_children()
	print('idx got ',idx,' ',self.name)
	if !trumps.get(idx):
		return
	var ace:Node3D = trumps[idx]
	var sprite:Sprite3D = ace.sprite
	var tween = create_tween().tween_property(sprite,'position',Vector3(0,3,0),.3)
	create_tween().tween_property(sprite,'modulate',Color(Color.WHITE,0.0),.3)
	create_tween().tween_property(sprite,'scale',Vector3.ZERO,.3)
	await tween.finished
	self.remove_child(ace)
	self.reformat()
func reformat():
	var x = 0
	for ace in get_children():
		var new_pos = Vector3(-0.08 * (x),0,0)
		x += 1
		if ace.position == new_pos:
			continue
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(ace,'position',new_pos,.1)
func draw_ace():
	var file = load('uid://dl8pitb0oors5')
	var new_ace:Node3D = ace_scene.instantiate()
	self.add_child(new_ace)
	new_ace.position = Vector3(-0.08 * (-1),0,0)
	new_ace.sprite.texture = file
	new_ace.sprite.modulate = Color(Color.WHITE,0.0)
	new_ace.sprite.scale = Vector3.ZERO
	new_ace.sprite.position = Vector3(-5.5,0,1)
	var tween = create_tween().tween_property(new_ace.sprite,'modulate',Color.WHITE,.2)
	create_tween().tween_property(new_ace.sprite,'position',Vector3.ZERO,.6)
	create_tween().tween_property(new_ace.sprite,'scale',Vector3.ONE,.2)
	await tween.finished
	await get_tree().create_timer(1).timeout
	self.remove_child(new_ace)
