extends Node3D

@onready var card_manager := $CardManager
@onready var sounds := $Sounds
#0 = yours
#1 = theirs
#2 = nobody
var turn = 2

func _ready() -> void:
	Client.poll_packets = true
	Client.got_packet.connect(received_packet)
	var packet = Packet.new()
	packet.event = 'init-game'
	Client.socket.send_text(packet.stringify())
func received_packet(packet_string):
	var packet:Packet = Packet.from_string(packet_string)
	match (packet.event):
		'init-cameras':
			init_cameras(packet.message)
			return
		#TODO obscure the number of the others hidden cards to prevent cheating
		'disband':
			Client.poll_packets = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print('heloo?')
			get_tree().change_scene_to_file("res://test_multiplayer.tscn")
		'p1-draw':
			var message:Dictionary = JSON.parse_string(packet.message)
			if not message.has('init'):
				sounds.draw_card(message.yours)
			card_manager.draw_p1(message)
		'p2-draw':
			var message:Dictionary = JSON.parse_string(packet.message)
			if not message.has('init'):
				sounds.draw_card(message.yours)
			card_manager.draw_p2(message)
		'p1-pass':
			var message:Dictionary = JSON.parse_string(packet.message)
			sounds.pass_turn(message.yours)
		'p2-pass':
			var message:Dictionary = JSON.parse_string(packet.message)
			sounds.pass_turn(message.yours)
		'p1-val':
			card_manager.update_val_p1(JSON.parse_string(packet.message))
		'p2-val':
			card_manager.update_val_p2(JSON.parse_string(packet.message))
		'p1-turn':
			card_manager.p1_light.show()
			card_manager.p2_light.hide()
			var you = packet.message
			if you:
				turn = 0
			else:
				turn = 1
		'p2-turn':
			card_manager.p1_light.hide()
			card_manager.p2_light.show()
			var you = packet.message
			if you:
				turn = 0
			else:
				turn = 1
		'no-turn':
			turn = 2
		'winner':
			turn = 3
			winner_scene(packet.message)
func zoom_camera():
	var tween = create_tween().tween_property($RevealCam,'fov',20,1.5)
	await tween.finished
func zoom_out():
	var tween = create_tween().tween_property($RevealCam,'fov',75,.3)
	await tween.finished
func p2_lose():
	var tween = create_tween().tween_property($P2Light,'light_energy',0,1)
	create_tween().tween_property($P2Light,'light_color',Color.DARK_RED,1)
	await tween.finished
	$p2hand.hide()
	$P2Light.light_color = Color.WHITE
	$P2Light.hide()
	$p2hand_value.hide()
func p1_lose():
	var tween = create_tween().tween_property($P1Light,'light_energy',0,1)
	create_tween().tween_property($P1Light,'light_color',Color.DARK_RED,1)
	await tween.finished
	$p1hand.hide()
	$P1Light.light_color = Color.WHITE
	$P1Light.hide()
	$p1hand_value.hide()
func winner_scene(message):
	print(message)
	$RevealCam.make_current()
	$MoodLight.hide()
	$P1Light.hide()
	$P2Light.hide()
	$p1hand_value.hide()
	$p2hand_value.hide()
	var winner = int(message[0])
	var pNum = int(message[1])
	var p1cards = message[2]
	var p2cards = message[3]
	var p1val = message[4]
	var p2val = message[5]
	$p1hand_value.text = str(int(p1val))
	$p2hand_value.text = str(int(p2val))
	
	$p1hand.add_cards(p1cards)
	$p2hand.add_cards(p2cards)
	$p1hand.hide_cards()
	$p2hand.hide_cards()
	push_warning(pNum)
	
	match pNum:
		1:
			push_warning('1')
			$P1Light.show()
			$p1hand.show_all()
			$p2hand.rotation_degrees.y = -180
			$p1hand_value.show()
			await get_tree().create_timer(1).timeout
			await zoom_camera()
			$P2Light.show()
			$p2hand.show_all()
			$p2hand_value.show()
			await zoom_out()
			await get_tree().create_timer(1).timeout
			if winner == pNum:
				p2_lose()
			else:
				p1_lose()
		2:
			push_warning('2')
			$RevealCam.rotation_degrees.y = 180
			$p1hand.rotation_degrees.y = 0
			$P2Light.show()
			$p2hand.show_all()
			$p2hand_value.show()
			await get_tree().create_timer(1).timeout
			await zoom_camera()
			$P1Light.show()
			$p1hand.show_all()
			$p1hand_value.show()
			await zoom_out()
			await get_tree().create_timer(1).timeout
			if winner != pNum:
				p2_lose()
			else:
				p1_lose()
func init_cameras(string_pdata:String):
	var playerData = JSON.parse_string(string_pdata)
	var num = playerData.playernum
	push_error('Is player ' + str(num))
	match num:
		1.0:
			$Player1/Camera3D.make_current()
			return
		2.0:
			$Player2/Camera3D.make_current()
