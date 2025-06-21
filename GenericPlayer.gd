extends Node

var socket: WebSocketPeer

var id = '':
	set = set_id

var poll_packets : bool = false

signal id_recieved(id)
signal got_packet(packet)

var has_id = false

func set_id(val:String):
	id = val
	if has_id:
		return
	has_id = true
	id_recieved.emit(id)

func _process(_delta):
	if not poll_packets or not has_id:
		return
	socket.poll()
	if socket.get_ready_state() != WebSocketPeer.STATE_OPEN:
		return
	while socket.get_ready_state() == WebSocketPeer.STATE_OPEN and socket.get_available_packet_count():
		push_error('got packet')
		var packet : PackedByteArray = socket.get_packet()
		
		got_packet.emit(packet.get_string_from_utf8())
