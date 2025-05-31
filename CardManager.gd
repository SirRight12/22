extends Node

var deck = ['1','2','3','4','5','6','7','8','9','10','11']
var p1hand = []
var p1hidden_hand = []
var p2hidden_hand = []
var p2hand = []
var can_draw = true
var card_space = 0.107
enum TURNS{P1,P2,REVEAL}
var turn = TURNS.P1
var card_pos = Vector3(0.689,0.58,-0.082)
signal p1carddrawn()
signal p2carddrawn()
@onready var p1node = get_tree().current_scene.find_child('p1hand')
@onready var p2node = get_tree().current_scene.find_child('p2hand')
@onready var p1_hand_val = get_tree().current_scene.find_child('p1hand_value')
@onready var p2_hand_val = get_tree().current_scene.find_child('p2hand_value')
@onready var UI:CanvasLayer = get_tree().current_scene.find_child('Canvas')
@onready var blackout = UI.find_child('Control',true)
@onready var p1:Node3D = get_tree().current_scene.find_child('Player1')
@onready var p2:Node3D = get_tree().current_scene.find_child('Player2')
@onready var p1cam:Camera3D = p1.find_child('Camera3D')
@onready var p2cam:Camera3D = p2.find_child('Camera3D')
@onready var revealcam:Camera3D = get_tree().current_scene.find_child('RevealCam')
@onready var p1_light:SpotLight3D = get_tree().current_scene.find_child('P1Light')
@onready var p2_light:SpotLight3D = get_tree().current_scene.find_child('P2Light')
@onready var mood_light:SpotLight3D = get_tree().current_scene.find_child('MoodLight')
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
		p1_passed = false
		p2_passed = false
		p1draw()
		await p1carddrawn
		await timeout(1)
		blackout.show()
		p1_light.hide()
		p2cam.make_current()
		await timeout(3)
		blackout.hide()
		p2_light.show()
		turn = TURNS.P2
		can_draw = true
	elif turn == TURNS.P2:
		can_draw = false
		p1_passed = false
		p2_passed = false
		p2draw()
		await p2carddrawn
		await timeout(1)
		blackout.show()
		turn = TURNS.P1
		await timeout(3)
		p1_light.show()
		p2_light.hide()
		p1cam.make_current()
		blackout.hide()
		can_draw = true
	swap_view()
var p1_passed = false
var p2_passed = false
func reset():
	clear_children(p1node)
	clear_children(p2node)
	p1hand = []
	p2hand = []
	p1hidden_hand = []
	p2hidden_hand = []
	p1_passed = false
	p2_passed = false
	reset_deck()
	turn = TURNS.P1
	p1_hand_val.show()
	p2_hand_val.show()
	p2node.rotation = Vector3(0,PI,0)
	p1_light.disabled = false
	p2_light.disabled = false
	p1_light.light_color = Color.WHITE
	p2_light.light_color = Color.WHITE
	p1cam.make_current()
	mood_light.show()
	p2_light.hide()
	swap_view()
	await cards_setup()
	
	
func pass_turn():
	if turn == TURNS.P1:
		p1_passed = true
		turn = TURNS.P2
		can_draw = false
		await timeout(1)
		blackout.show()
		turn = TURNS.P2
		p2cam.make_current()
		await timeout(3)
		blackout.hide()
		if p1_passed and p2_passed:
			turn = TURNS.REVEAL
			reveal()
			return
		p2_light.show()
		p1_light.hide()
		can_draw = true
	elif turn == TURNS.P2:
		p2_passed = true
		
		turn = TURNS.P2
		can_draw = false
		await timeout(1)
		blackout.show()
		turn = TURNS.P1
		p1cam.make_current()
		await timeout(3)
		blackout.hide()
		if p1_passed and p2_passed:
			turn = TURNS.REVEAL
			reveal()
			return
		p1_light.show()
		p2_light.hide()
		
		can_draw = true
	
	swap_view()
func reveal():
	swap_view()
	mood_light.hide()
	p1_light.hide()
	p2_light.hide()
	p1_hand_val.hide()
	p2_hand_val.hide()
	p1_light.spot_angle = 20
	p2_light.spot_angle = 20
	revealcam.make_current()
	await timeout(2)
	reveal_children(p1node)
	p1_light.show()
	await timeout(1)
	create_tween().tween_property(revealcam,'fov',35,1.5)
	await timeout(2)
	p2node.rotation_degrees = Vector3.ZERO
	reveal_children(p2node)
	p2_light.show()
	create_tween().tween_property(revealcam,'fov',75,.2)
	await timeout(1)
	winner()
	await timeout(3)
	reset()
func winner():
	var win = eval_winner()
	if win == TURNS.P1:
		p2node.hide_cards()
		p2_light.disabled = true
		create_tween().tween_property(p2_light,'light_color',Color.RED,.4)
		create_tween().tween_property(p2_light,'light_energy',0,1)
	else:
		p1node.hide_cards()
		p1_light.disabled = true
		create_tween().tween_property(p1_light,'light_color',Color.RED,.4)
		create_tween().tween_property(p1_light,'light_energy',0,1)

	
func eval_winner():
	var p1 = int(value_of(p1hand))
	var p2 = int(value_of(p2hand))
	#if the first hand is more than the second
	if p1 > p2:
		#if p1 busted then p2 must be either under, or at least less
		if p1 > current_target:
			return TURNS.P2
		#Otherwise p1 has not busted and bested p2 so they win
		else:
			return TURNS.P1
	# p2 >= p1
	else:
		if p2 > current_target:
			return TURNS.P1
		else:
			return TURNS.P2
	
func reveal_children(hand:Node3D):
	for node in hand.get_children():
		node.hidden = false
func swap_view():
	if turn == TURNS.P1:
		p1node.show_all()
		p2node.hide_all()
		p1_hand_val.text = str(value_of(p1hand)) + '/' + str(current_target)
		p2_hand_val.text = str(value_of(p2hidden_hand)) + '/' + str(current_target)
	elif turn == TURNS.P2:
		p2node.show_all()
		p1node.hide_all()
		p1_hand_val.text = str(value_of(p1hidden_hand)) + '/' + str(current_target)
		p2_hand_val.text = str(value_of(p2hand)) + '/' + str(current_target)
	else:
		p2node.hide_cards()
		p1node.hide_cards()
		p1_hand_val.text = str(value_of(p1hand)) + '/' + str(current_target)
		p2_hand_val.text = str(value_of(p2hand)) + '/' + str(current_target)
func _ready() -> void:
	clear_children(p1node)
	cards_setup()
func cards_setup():
	reset_deck()
	p1draw(true)
	p2draw(true)
	await p1carddrawn
	await timeout(.4)
	p1draw()
	p2draw()
func value_of(hand:Array):
	var total = 0
	var starting = ''
	for val in hand:
		if not val:
			starting = '?+'
		total += int(val)
	return starting + str(total)
		
@onready var card_scene = load('res://card.tscn')
func p1draw(hidden:bool=false):
	var idx = 0
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
	
	
	deck.pop_at(idx)
	can_draw = false
	if not node.is_node_ready():
		await node.ready
	var tween = create_tween()
	tween.tween_property(node,'position',final,.3)
	node.slide()
	await tween.finished
	swap_view()
	can_draw = true
	p1carddrawn.emit()
	#p1_hand_val.text = str(value_of(p1hidden_hand)) + '/' + str(current_target)
func p2draw(hidden:bool=false):
	var idx = 0
	var card = deck[idx]
	var node = card_scene.instantiate()
	p2hand.append(card)
	if hidden:
		p2hidden_hand.append(false)
	else:
		p2hidden_hand.append(card)
	p2node.add_child(node)
	node.value = int(card)
	node.hidden = hidden
	var final = Vector3(card_space * (len(p2hand) - 1),0,0)
	node.position = card_pos
	node.show()
	
	
	deck.pop_at(idx)
	can_draw = false
	if not node.is_node_ready():
		await node.ready
	var tween = create_tween()
	tween.tween_property(node,'position',final,.3)
	node.slide()
	await tween.finished
	p2_hand_val.text = str(value_of(p2hidden_hand)) + '/' + str(current_target)
	can_draw = true
	p2carddrawn.emit()
	swap_view()
	#p1_hand_val.text = str(value_of(p1hidden_hand)) + '/' + str(current_target)
func timeout(time:float):
	var timer = get_tree().create_timer(time)
	await timer.timeout
	return
func clear_children(hand:Node3D):
	for child in hand.get_children():
		hand.remove_child(child)
