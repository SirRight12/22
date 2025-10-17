extends Node3D

@onready var card_manager := $CardManager
@onready var sounds := $Sounds
@onready var trump_ui = $Canvas/Control2
# TURNS
#0 = yours
#1 = theirs
#2 = nobody
var turn = 2
@onready var p1_clock_ui = $p1clock/UI/Control
@onready var p2_clock_ui = $p2clock/UI/Control
var turn_clock = Timer.new()
var clock
func _ready() -> void:
	Client.poll_packets = true
	Client.got_packet.connect(received_packet)
	var packet = Packet.new()
	packet.event = 'init-game'
	Client.socket.send_text(packet.stringify())
	add_child(turn_clock)
	turn_clock.one_shot = true
func received_packet(packet_string):
	var packet:Packet = Packet.from_string(packet_string)
	match (packet.event):
		'init-cameras':
			init_cameras(packet.message)
			return
		'update-clock':
			var info:Dictionary = JSON.parse_string(packet.message)
			turn_clock.wait_time = info.time
			if not clock:
				if int(info.playernum) == 1:
					clock = p1_clock_ui
				else:
					clock = p2_clock_ui
			clock.set_information(int(info.get('round',1)),int(info.get('ante',1)),int(info.get('hp',7)))
		'disband':
			Client.poll_packets = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			print('heloo?')
			get_tree().change_scene_to_file("res://test_multiplayer.tscn")
		'p1-draw':
			var message:Dictionary = JSON.parse_string(packet.message)
			print('drawing card')
			push_warning('packet',message)
			if not message.has('init') and not message.has('trump'):
				sounds.draw_card(message.yours)
			card_manager.draw_p1(message)
		'p1-draw-trump':
			var message = packet.message
			if card_manager.has_method('slide_trump'):
				card_manager.slide_trump('p1')
			if not message:
				return
			trump_ui.aces.append(message)
			trump_ui.got_aces(trump_ui.aces)
		'update-client-trumps':
			print('help!')
			var message = JSON.parse_string(packet.message)
			trump_ui.aces = message
			trump_ui.got_aces(trump_ui.aces)
		'p2-draw-trump':
			var message = packet.message
			if card_manager.has_method('slide_trump'):
				card_manager.slide_trump('p2')
			if not message:
				return
			trump_ui.aces.append(message)
			trump_ui.got_aces(trump_ui.aces)
		'p2-draw':
			var message:Dictionary = JSON.parse_string(packet.message)
			if not message.has('init') and not message.has('trump'):
				sounds.draw_card(message.yours)
			if message.has('trump'):
				sounds.trump_sound()
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
				turn_clock.start()
			else:
				turn_clock.stop()
				turn = 1
		'p1-remove-last':
			card_manager.remove_last_p1()
			return
		'p2-remove-last':
			card_manager.remove_last_p2()
			return
		'p1-remove-all':
			card_manager.remove_all_p1()
			return
		'p2-remove-all':
			card_manager.remove_all_p2()
			return
		'p2-turn':
			card_manager.p1_light.hide()
			card_manager.p2_light.show()
			var you = packet.message
			if you:
				turn = 0
				turn_clock.start()
			else:
				turn_clock.stop()
				turn = 1
		'no-turn':
			turn_clock.stop()
			turn = 2
		'winner':
			turn_clock.stop()
			turn = 3
			winner_scene(packet.message)
		'new-round':
			sounds.bg_music.play()
			turn = 2
			card_manager.p1_light.show()
			card_manager.p2_light.hide()
			card_manager.mood_light.show()
			card_manager.p1_light.light_color = Color.WHITE
			card_manager.p2_light.light_color = Color.WHITE
			card_manager.p1node.clear_children()
			card_manager.p1node.show()
			card_manager.p2node.show()
			card_manager.p1node.rotation_degrees.y = -180.0
			card_manager.p2node.rotation_degrees.y = 0.0
			card_manager.p2node.clear_children()
			card_manager.p1_hand_val.show()
			card_manager.p2_hand_val.show()
			card_manager.p2_hand_val.text = '0/21'
			card_manager.p1_hand_val.text = '0/21'
		'game-win':
			$Canvas/Win.show()
			$Canvas/Win.display_text()
			game_over()
		'game-lose':
			$Canvas/Lose.show()
			$Canvas/Lose.display_text()
			game_over()
func game_over():
	get_tree().paused = true
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
	sounds.bg_music.playing = false
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
				sounds.win()
			elif winner != 3:
				sounds.lose()
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
				sounds.lose()
			elif winner != 3:
				p1_lose()
				sounds.win()
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
func _process(delta: float) -> void:
	if not turn_clock.is_stopped():
		set_clock_time(floor(turn_clock.time_left))
func set_clock_time(time:int):
	var minutes = floor(time / 60)
	var seconds = time - (minutes * 60)
	var time_text = str(minutes) + ':' + format_seconds(seconds)
	clock.set_time(time_text)
func format_seconds(seconds) -> String:
	if seconds < 10:
		return '0' + str(seconds)
	return str(seconds)
	
