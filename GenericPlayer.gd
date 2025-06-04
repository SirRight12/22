extends Node

var socket: WebSocketPeer

var id = '':
	set = set_id

signal id_recieved(id)

var has_id = false

func set_id(val:String):
	id = val
	if has_id:
		return
	has_id = true
	id_recieved.emit(id)
