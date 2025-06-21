extends "res://CardManager.gd"
class_name SocketCardManager

func draw_p1(server_message):
	print(server_message)
	var yours = server_message.yours
	var server_card = JSON.parse_string(server_message.card)
	var card = int(server_card.value)
	var node = card_scene.instantiate()
	p1node.add_child(node)
	node.value = int(card)
	node.is_owner = yours
	node.hidden = server_card.hidden
	var final = Vector3(-card_space * (len(p1node.get_children()) - 1),0,0)
	node.position = card_pos
	node.show()
	
	if not server_message.yours and server_card.hidden:
		node.value = 1
	if not node.is_node_ready():
		await node.ready
	var tween = create_tween()
	tween.tween_property(node,'position',final,.3)
	node.slide()
func draw_p2(server_message):
	print(server_message)
	var yours = server_message.yours
	var server_card = JSON.parse_string(server_message.card)
	var card = int(server_card.value)
	var node = card_scene.instantiate()
	p2node.add_child(node)
	node.value = int(card)
	node.is_owner = yours
	node.hidden = server_card.hidden
	var final = Vector3(-card_space * (len(p2node.get_children()) - 1),0,0)
	node.position = card_pos
	node.show()
	# Preventing the client from storing the value of a card that they're not supposed to see
	if not server_message.yours and server_card.hidden:
		node.value = 1
	
	if not node.is_node_ready():
		await node.ready
	var tween = create_tween()
	tween.tween_property(node,'position',final,.3)
	node.slide()
#override the parent ready function
func _ready():
	pass
func update_val_p1(message:Dictionary):
	var hidden = ''
	if message.hcount > 0 and not message.yours:
		hidden = '?+'
	p1_hand_val.text = hidden + str(int(message.value)) + '/' + str(int(message.target))
func update_val_p2(message:Dictionary):
	var hidden = ''
	if message.hcount > 0 and not message.yours:
		hidden = '?+'
	p2_hand_val.text =  hidden + str(int(message.value)) + '/' + str(int(message.target))
