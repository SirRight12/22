extends Control

@onready var host:Button = $Host
@onready var join:Button = $Joining/Join
@onready var join_code:LineEdit = $Joining/LineEdit
@onready var joining:Control = $Joining
@onready var Players = $Players
@onready var start:Button = $Start
@onready var lobby_id_ui:Control = $ID_UI
@onready var lobby_code:LineEdit = $ID_UI/ID
@export var max_lobby_size:int = 2
@export var lobby_id_length:int = 10
var peer := ENetMultiplayerPeer.new()
var lobbies = {}
var player_list = {}

func generate_uid():
	var string = ''
	var x = 0
	while x < lobby_id_length:
		string += str(randi_range(0,9))
		x += 1
	return string
func client_init():
	push_error('Is a client instance')
	peer.create_client('localhost',5500)
	multiplayer.multiplayer_peer = peer
	host.pressed.connect(host_click)
	join.pressed.connect(join_click)

func _ready():
	if not OS.has_feature('dedicated_server'):
		client_init()
		print('is not the dedicated server')
		return
	server_init()
func server_init():
	push_error('Is the Server Instace')
	peer.create_server(5500,32)
	multiplayer.multiplayer_peer = peer
	peer.peer_disconnected.connect(_on_disconnect)
func host_click():
	rpc_id(1,'host_lobby',multiplayer.get_unique_id())
func join_click():
	rpc_id(1,'join_lobby',multiplayer.get_unique_id(),int(join_code.text))
func start_click():
	rpc_id(1,'start_lobby',multiplayer.get_unique_id())
@onready var error_scene:PackedScene = load('res://error.tscn')
## Debug function to send an error message straight to a client error evaluator
## it assists in debugging as it shows which client generated the error
@rpc ('authority','call_remote')
func server_error(message):
	var error_inst = error_scene.instantiate()
	add_child(error_inst)
	error_inst.label.text = 'Error\n\n' + message
	push_error(message)
@rpc('any_peer')
func host_lobby(client_id:int) -> void:
	if not multiplayer.is_server():
		return
	#continue trying to generate codes if they are used
	var i = 0
	var lobby_uid = generate_uid()
	while lobbies.has(lobby_uid):
		lobby_uid = generate_uid()
		i += 1
		if i > 100:
			rpc_id(client_id,'server_error',"Couldn't generate a code within 1000 iters")
			return
	lobbies[lobby_uid] = []
	var lobby:Array = lobbies[lobby_uid]
	var player := GenericPlayer.new()
	player.id = client_id
	player.is_host = true
	lobby.append(player)
	push_warning(lobbies)
	rpc_id(client_id,'success_host',player.to_dict(),lobby_uid)
@rpc('any_peer')
func join_lobby(client_id:int,_lobby_id:int=0) -> void:
	push_warning(client_id)
	if not lobbies.has(str(_lobby_id)):
		rpc_id(client_id,'server_error',"No lobby found with specified id")
		return
	var lobby = lobbies[str(_lobby_id)]
	if len(lobby) + 1 > max_lobby_size:
		rpc_id(client_id,'server_error','Given lobby is full')
		return
	var player = GenericPlayer.new()
	var client_lobby = []
	for p:GenericPlayer in lobby:
		client_lobby.append(p.to_dict())
	player.id = client_id
	rpc_players(lobby,'player_join',player.to_dict())
	lobby.append(player)
	client_lobby.append(player.to_dict())
	rpc_id(client_id,'success_join',client_lobby,str(_lobby_id))
@rpc('any_peer')
func start_lobby(client_id):
	if not multiplayer.is_server():
		return
	for lobby_id:String in lobbies:
		var lobby = lobbies[lobby_id]
		for player in lobby:
			if player.id == client_id:
				if not player.is_host:
					rpc_id(client_id,'server_error','Cannot start lobby unless you are the host')
					return
				if len(lobby) < 2:
					rpc_id(client_id,'server_error','You must have at least 2 players to start')
					return
				start_server(lobby_id)
				return
		rpc_id(client_id,'server_error','Client is not inside a lobby')
	pass

func lobby_ui_time():
	host.hide()
	joining.hide()
	Players.show()
	lobby_id_ui.show()
@rpc('authority','call_remote')
func success_host(player,lobby_id:String):
	lobby_ui_time()
	start.show()
	lobby_code.text = lobby_id
	start.pressed.connect(start_click)
	player_join(player)
@rpc('authority')
func player_join(player):
	var prefix = ''
	if player.is_host:
		prefix = '(Host)'
	
	if player.id == multiplayer.get_unique_id():
		prefix = '(You)'
		
	Players.add_item(prefix + ' ' + str(player.id),load(player.icon_path))
	pass
@rpc('authority')
func success_join(lobby,lobby_id):
	lobby_ui_time()
	lobby_code.text = lobby_id
	for player in lobby:
		player_join(player)
func rpc_players(p_list,method_name:String,arg):
	for player:GenericPlayer in p_list:
		rpc_id(player.id,method_name,arg)
##Function to remove clients from a lobby should the host leave
@rpc('authority')
func disbanded(_arg):
	Players.clear()
	Players.hide()
	host.show()
	start.hide()
	joining.show()
	lobby_id_ui.hide()
##Function to force the update of the player list when a player is in a lobby
@rpc('authority')
func override_list(lobby):
	Players.clear()
	for player:Dictionary in lobby:
		player_join(player)
func lobby_to_client(lobby):
	var client_lobby = []
	for player:GenericPlayer in lobby:
		client_lobby.append(player.to_dict())
	return client_lobby
func _on_disconnect(_id:int) -> void:
	if not multiplayer.is_server():
		return
	for lobby_id in lobbies:
		var lobby = lobbies[lobby_id]
		var i = 0
		for player:GenericPlayer in lobby:
			
			if player.id == _id:
				
				if lobby[i].is_host:
					lobby.pop_at(i)
					lobbies.erase(lobby_id)
					push_error('Lobby disbanded by host disconnection')
					rpc_players(lobby,'server_error','Lobby disbanded by disconnection')
					rpc_players(lobby,'disbanded',null)
					return
				lobby.pop_at(i)
				if len(lobby) > 0:
					rpc_players(lobby,'override_list',lobby_to_client(lobby))
					return
				push_error('lobby disbanded because no players')
				lobbies.erase(lobby_id)
			i += 1
@rpc('authority')
func transfer_scene(_arg):
	Transfer.lobby_id = _arg
	get_tree().change_scene_to_file('uid://bfc5d01gu77ey')
	pass
func start_server(lobby_id:String):
	if not multiplayer.is_server():
		return
	push_warning('Starting lobby ' + lobby_id)
	var lobby = lobbies[lobby_id]
	var server = Server.new()
	server.name = 'Lobby' + lobby_id
	get_tree().root.add_child(server)
	server.server_init(lobby)
	rpc_players(lobby,'transfer_scene',lobby_id)
	pass
