extends Node3D

@onready var p1cam:Camera3D = $Player1/Camera3D
@onready var p2cam:Camera3D = $Player2/Camera3D
@onready var Cardmanager = $CardManager
# Called when the node enters the scene tree for the first time.
var peers_connected = []
func _ready() -> void:
	if not multiplayer.is_server():
		rpc_id(1,'connected',multiplayer.get_unique_id())
		return
	if len(multiplayer.get_peers()) == 1:
		var id_other = multiplayer.get_peers()[0]
		Cardmanager.players[1] = '1'
		Cardmanager.players[id_other] = '2'
		p1cam.make_current()
		rpc_id(id_other,'set_camera',2)
		Cardmanager.players_recieved.emit()
	elif len(multiplayer.get_peers()) > 1:
		var peers = multiplayer.get_peers()
		var p1_idx = randi_range(0,1)
		# 1 - (1) = 0 
		# 1 - (0) = 1
		var p2_idx = 1 - p1_idx
		var p1_id = peers[p1_idx]
		var p2_id = peers[p2_idx]
		Cardmanager.players[p1_id] = '1'
		Cardmanager.players[p2_id] = '2'
		rpc_id(p1_id,'set_camera',1)
		rpc_id(p2_id,'set_camera',2)
		Cardmanager.players_recieved.emit()
		
	peers_connected.append(1)
@rpc("any_peer")
func connected(peer_id):
	peers_connected.append(peer_id)
	print(peer_id,' connected')
@rpc('any_peer')
func set_camera(cam_id):
	if cam_id == 1:
		p1cam.make_current()
	elif cam_id == 2:
		p2cam.make_current()
