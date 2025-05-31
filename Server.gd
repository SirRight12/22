extends Node
class_name Server
var peers_to_connect = {}
func _ready():
	if not multiplayer.is_server():
		rpc_id(1,'_check_in',multiplayer.get_unique_id())
		pass
func server_init(lobby):
	for player in lobby:
		peers_to_connect[player.id] = true
	pass
@rpc("any_peer")
func _check_in(id):
	if not multiplayer.is_server():
		return
	if peers_to_connect.has(id):
		peers_to_connect.erase(id)
		push_error('checked in')
