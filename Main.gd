extends Control
@export var player_scene:PackedScene
@onready var host:Button = $Host
@onready var join:Button = $Join
@onready var Players = $Players
@onready var start:Button = $Start
var peer := ENetMultiplayerPeer.new()
var peers = [peer]
func _ready():
	join.pressed.connect(find_lobby)
	host.pressed.connect(create_lobby)
func loaded():
	host.hide()
	join.hide()
	Players.show()
func find_lobby():
	peer.create_client('localhost',135)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(add_player_list)
	loaded()
func add_item(id,is_self=false):
	var prefix = ''
	if id == 1:
		prefix = '(Host) '
	if is_self:
		prefix = '(You) '
	Players.add_item(prefix + 'Player-' + str(id),load("res://icon.svg"),false)

func add_player_list():
	print(multiplayer.get_peers())
	for id in multiplayer.get_peers():
		add_item(id)
	add_item(multiplayer.get_unique_id(),true)
func create_lobby():
	peer.create_server(135,2)
	add_item(peer.get_unique_id())
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(add_item)
	#multiplayer.peer_disconnected.connect(_remove_player)
	loaded()
	start.show()
	start.pressed.connect(start_lobby)
func start_lobby():
	if not multiplayer.is_server():
		printerr("How did you..., forget it, scram client")
	rpc('transfer_lobby')
func _remove_player(id):
	var player = find_child('player-' + str(id),true)
	remove_child(player)
@onready var other:PackedScene = load('res://multiplayer_22.tscn')
@rpc('authority','call_local',"unreliable") func transfer_lobby():
	get_tree().change_scene_to_packed(other)
