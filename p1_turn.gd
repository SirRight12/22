extends Node3D

@onready var card_manager:SocketCardManager = $"../CardManager"
@onready var card_scene:PackedScene = load("res://card.tscn")

func show_all():
	for child in get_children():
		child.true_num()
func hide_all():
	for child in get_children():
		child.hidden_num()
func hide_cards():
	for child in get_children():
		child.hide_num()
func add_cards(cards:Array):
	for child in get_children():
		remove_child(child)
	var added = 0
	for card in cards:
		var inst = card_scene.instantiate()
		inst.value = card.value
		inst.hidden = false
		inst.rotation_degrees = Vector3(90,0,0)
		inst.position = Vector3(card_manager.card_space * (added - 1),0,0)
		add_child(inst)
		added += 1
