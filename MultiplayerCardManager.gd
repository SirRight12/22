extends "res://CardManager.gd"

var players:Dictionary = {}
signal recieved_turn(turn)
signal recieved_hands(hands)
var recieved_players = false
signal players_recieved()
@rpc('authority','call_local')
func swap_view():
	if not recieved_players:
		await players_recieved
	push_error('got players')
	var id = multiplayer.get_unique_id()
	var self_id = players[id]
	rpc('authenticate_hands',id)
	var hands = await recieved_hands
	print('override!')
	var p1_h = hands[0]
	var p1_hh = hands[1]
	var p2_h = hands[2]
	var p2_hh = hands[3]
	#Player one
	push_warning('p',self_id,': ',hands)
	if self_id == '1':
		var val1 = value_of(p1_h)
		var val2 = value_of(p2_hh)
		p1node.show_all()
		p2node.hide_all()
		p1_hand_val.text = str(val1) + '/' + str(current_target)
		p2_hand_val.text = str(val2) + '/' + str(current_target)
	elif self_id == '2':
		var val1 = value_of(p1_hh)
		var val2 = value_of(p2_h)
		p1node.hide_all()
		p2node.show_all()
		p1_hand_val.text = str(val1) + '/' + str(current_target)
		p2_hand_val.text = str(val2) + '/' + str(current_target)

func _ready() -> void:
	if not multiplayer.is_server():
		print('is not server')
		return
	print('is the server')
	if not recieved_players:
		await players_recieved
	recieved_players = true
	rpc('give_players',players)
	reset_deck()
	broadcast_peers('set_deck',deck)
	rpc('draw_p1',true)
	rpc('draw_p2',true)
	await p1carddrawn
	rpc('draw_p1',false)
	rpc('draw_p2',false)
func broadcast_peers(method_name,args=null):
	if not multiplayer.is_server():
		return
	for peer in multiplayer.get_peers():
		rpc_id(peer,method_name,args)
@rpc('authority',"call_remote",'reliable')
func give_players(p):
	push_error('players',p)
	players = p
	recieved_players = true
	players_recieved.emit()
#any peer may call this,but only the server may recieve it.
@rpc('any_peer')
func authenticate_turn(id_from):
	if not multiplayer.is_server():
		print("HEY, you're not the owner")
		return 
	rpc_id(id_from,'set_turn',turn)
@rpc('any_peer','call_local')
func authenticate_hands(id_from):
	print('hello?')
	if not multiplayer.is_server():
		return
	print('giving hands')
	rpc_id(id_from,'give_hands',p1hand,p1hidden_hand,p2hand,p2hidden_hand)
@rpc('authority','call_local')
func give_hands(p1h,p1_hh,p2_h,p2_hh):
	recieved_hands.emit([p1h,p1_hh,p2_h,p2_hh])
#only the server can call this
@rpc('authority','call_local')
func set_turn(passed_turn):
	turn = passed_turn
	recieved_turn.emit(passed_turn)
	pass
#only server may call, calls to server as well
@rpc('authority','call_local')
func draw_p1(hidden):
	print('draw ',deck)
	p1draw(hidden)
	if multiplayer.is_server():
		rpc('swap_view')
#only server may call, calls to server as well
@rpc('authority','call_local')
func draw_p2(hidden:bool) -> void:
	print('draw2 ',deck)
	p2draw(hidden)
	if multiplayer.is_server():
		rpc('swap_view')
#only server may call and only to clients as the deck is already set
@rpc('authority','call_remote')
func set_deck(val):
	print('deck set')
	deck = val
