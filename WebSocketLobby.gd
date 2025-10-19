extends Control

@onready var host:Button = $Host

@onready var joining:Control = $Joining
@onready var join:Button = $Joining/Join
@onready var join_code:LineEdit = $Joining/LineEdit

@onready var start:Button = $Start
@onready var disband:Button = $Disband

@onready var players:ItemList = $Players

@onready var id_ui:Control = $ID_UI
##LineEdit that shows the ID of the lobby the client is in
@onready var lobby_id_ui:LineEdit = $ID_UI/ID

@onready var leave : Button = $Leave


var socket : WebSocketPeer

signal got_packet(message)
#var web : WebSocketPeer
const PORT = 5500
var prev_state = WebSocketPeer.STATE_CLOSED

func init_client():
	socket = WebSocketPeer.new()
	#official build
	print(OS.has_feature('release'))
	if OS.has_feature('release'):
		socket.connect_to_url('wss://two2-mi7l.onrender.com')
	#debug testing
	else:
		socket.connect_to_url('ws://localhost:4000')
	Client.socket = socket
	got_packet.connect(_on_data)
	#socket = WebSocketMultiplayerPeer.new()
	#socket.create_client('ws://localhost:8080')
	#multiplayer.multiplayer_peer = socket
	
func _process(_delta: float) -> void:
	socket.poll()
	var state = socket.get_ready_state()
	if state != prev_state:
		if state == WebSocketPeer.STATE_OPEN:
			var packet := Packet.new()
			packet.event = 'init'
			packet.message = 'User has joined'
			socket.send_text(packet.stringify()) 
	prev_state = state
	while socket.get_ready_state() == WebSocketPeer.STATE_OPEN and socket.get_available_packet_count():
		var packet = socket.get_packet()
		got_packet.emit(packet.get_string_from_utf8())
@onready var error_scene: PackedScene = load("res://error.tscn")
func server_error(error:String):
	var inst: Control = error_scene.instantiate()
	add_child(inst)
	inst.label.text = error
func _on_data(data:String):
	print(data)
	var packet:Packet = Packet.from_string(data)
	match packet.event:
		'server_error':
			server_error(packet.message)
			return
		'init':
			on_init(packet)
			return
		'host_success':
			host_success(packet)
			return
		'update_player_list':
			parse_list(packet)
			return
		'join_success':
			join_success(packet)
			return
		'leave_success':
			leave_success(packet)
			return
		'start_success':
			start_lobby()
			return
	pass
func hide_ui():
	host.hide()
	start.hide()
	players.show()
	joining.hide()
	id_ui.show()

func disband_pressed():
	var packet = Packet.new()
	packet.event = 'leave'
	packet.message = ''
	socket.send_text(packet.stringify())

func start_pressed():
	var packet = Packet.new()
	packet.event = 'start'
	var dict = {
		'starting_hp': $"Start/Game Settings/Player Health".val,
		'round_time': $"Start/Game Settings/Round Time".val,
		'trump_per_round': $"Start/Game Settings/Trump Per Round".val,
	}
	
	packet.message = JSON.stringify(dict)
	socket.send_text(packet.stringify())

func host_success(packet:Packet):
	hide_ui()
	start.show()
	disband.show()
	disband.pressed.connect(disband_pressed)
	start.pressed.connect(start_pressed)
	var lobby = JSON.parse_string(packet.message)
	lobby_id_ui.text = lobby.id
	var player_list = JSON.parse_string(lobby['client_lobby'])
	update_player_list(player_list)

func leave_pressed():
	var packet = Packet.new()
	packet.event = 'leave'
	packet.message = Client.id
	socket.send_text(packet.stringify())

func leave_success(_packet:Packet):
	leave.hide()
	id_ui.hide()
	joining.show()
	start.hide()
	disband.hide()
	join_code.text = ''
	host.show()
	players.hide()
	players.clear()
	

func join_success(packet:Packet):
	hide_ui()
	leave.show()
	print(packet.message)
	leave.pressed.connect(leave_pressed,CONNECT_ONE_SHOT)
	lobby_id_ui.text = packet.message
	

func parse_list(packet:Packet):
	var player_list = JSON.parse_string(packet.message)
	update_player_list(player_list)
func update_player_list(player_list):
	players.clear()
	for idx:String in player_list:
		var player = JSON.parse_string(player_list[idx])
		var isHost = player.isHost
		var prefix = ''
		if isHost:
			prefix = '(Host) '
		if Client.id == player.id:
			prefix = '(You) '
		var player_name:String = player.display_name
		if player_name.length() < 1:
			player_name = 'Player ' + str(player.id)
		players.add_item(prefix + player_name,load("res://icon.svg"),false)
	
func host_clicked():
	var packet = Packet.new()
	
	packet.event = 'host'
	packet.message = $Joining/DisplayName.text
	socket.send_text(packet.stringify())
	
func join_clicked():
	var packet = Packet.new()
	packet.event = 'join'
	var lobby_id = join_code.text if not join_code.text.is_empty() else  DisplayServer.clipboard_get()
	var dname = $Joining/DisplayName.text
	packet.message = JSON.stringify({'id': lobby_id, 'display_name': dname,})
	socket.send_text(packet.stringify())
func on_init(packet:Packet):
	Client.id = packet.message
	
func start_lobby():
	get_tree().change_scene_to_file("res://multiplayer_22.tscn")
	pass
	
func _ready():
	init_client()
	host.pressed.connect(host_clicked)
	join.pressed.connect(join_clicked)



func _on_line_edit_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		join_clicked()
