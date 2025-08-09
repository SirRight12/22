extends CanvasLayer

func _ready():
	if Client.connected:
		self.hide()
	else:
		self.show()
		$AnimationPlayer.play('reconnect')
	Client.on_connected.connect(on_connection)
	Client.on_connection_lost.connect(on_disconnect)
func on_connection():
	self.hide()
	$AnimationPlayer.stop()
func on_disconnect():
	self.show()
	$AnimationPlayer.play('reconnect')
