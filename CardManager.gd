extends Node

var deck = ['1','2','3','4','5','6','7','8','9','10','11']
var p1hand = []
var p1hidden_hand = []
var p2hand = []
var can_draw = true
var card_space = 0.107
enum TURNS{P1,P2}
var turn = TURNS.P1
var card_pos = Vector3(0.689,0.58,-0.082)
signal p1carddrawn()
signal p2carddrawn()
@onready var p1node = get_tree().current_scene.find_child('p1hand')
@onready var p1_hand_val = get_tree().current_scene.find_child('p1hand_value')
# Called when the node enters the scene tree for the first time.
var current_target = 21
func shuffle_deck() -> Array[String]:
	var new_list:Array[String] = []
	new_list.resize(11)
	var used = {}
	var x = 0
	while x < 11:
		#try to get a random number from the deck
		var num = str(randi_range(1,11))
		while used.has(num):
			num = str(randi_range(1,11))
		used[num] = true
		new_list[x] = num
		x += 1
	
	print(new_list)
	return new_list
func reset_deck():
	deck = shuffle_deck()
func draw_card():
	if not can_draw:
		return
	if turn == TURNS.P1:
		can_draw = false
		p1draw()
		p1_hand_val.text = 'draw card? ' + str(len(p1hand))
		await p1carddrawn
		p1_hand_val.text = 'can draw again'
		can_draw = true
func _ready() -> void:
	clear_children(p1node)
	reset_deck()
	#p1draw(true)
func value_of(hand:Array):
	var total = 0
	var starting = ''
	for val in hand:
		if not val:
			starting = '+?'
		total += int(val)
	return starting + str(total)
		
@onready var card_scene = load('res://card.tscn')
func p1draw(hidden:bool=false):
	var idx = randi_range(0,len(deck) - 1)
	var card = deck[idx]
	var node = card_scene.instantiate()
	p1hand.append(card)
	if hidden:
		p1hidden_hand.append(false)
	else:
		p1hidden_hand.append(card)
	p1node.add_child(node)
	node.value = int(card)
	node.hidden = hidden
	var final = Vector3(card_space * (len(p1hand) - 1),0,0)
	node.position = card_pos
	node.show()
	p1_hand_val.text = str(len(p1hand)) +  ' ' + card + str(final) + ' '
	
	
	deck.pop_at(idx)
	can_draw = false
	if not node.is_node_ready():
		await node.ready
	var tween = create_tween()
	tween.tween_property(node,'position',final,.3)
	node.slide()
	p1_hand_val.text = 'ready? ' + node.is_node_ready()
	await tween.finished
	p1_hand_val.text = 'tween done'
	can_draw = true
	p1carddrawn.emit()
	#p1_hand_val.text = str(value_of(p1hidden_hand)) + '/' + str(current_target)
func timeout(time:float):
	var timer = get_tree().create_timer(time)
	await timer.timeout
	return
func clear_children(hand:Node3D):
	for child in hand.get_children():
		hand.remove_child(child)
