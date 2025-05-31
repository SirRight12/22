extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var server = Server.new()
	server.name = 'Lobby' + Transfer.lobby_id
	get_tree().root.add_child(server)
