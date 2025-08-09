extends Button

func _pressed() -> void:
	var packet = Packet.new()
	packet.event = 'use-trump'
	packet.message = 'Perfect Draw'
	Client.socket.send_text(packet.stringify())
	pass
