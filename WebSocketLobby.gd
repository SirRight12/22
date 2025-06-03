extends Control

var socket : WebSocketPeer

#var web : WebSocketPeer
const PORT = 5500
var prev_state = WebSocketPeer.STATE_CLOSED

func init_client():
	socket = WebSocketPeer.new()
	socket.connect_to_url('ws://localhost:8080')
	#socket = WebSocketMultiplayerPeer.new()
	#socket.create_client('ws://localhost:8080')
	#multiplayer.multiplayer_peer = socket
	
func _process(delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	if state != prev_state:
		if state == WebSocketPeer.STATE_OPEN:
			var packet := Packet.new()
			packet.event = 'Help'
			packet.message = 'HELPPPPP'
			socket.send_text(packet.stringify()) 
	prev_state = state
	print(socket.get_ready_state())

	
func _on_data():
	pass

func _ready():
	init_client()
