extends "res://ControlDrawing.gd"

@onready var game = $".."
@onready var sounds = $"../Sounds"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('view'):
		if $Control2.is_open:
			$Control2.close()
		elif $Control2.is_close:
			$Control2.open()
			pass
		return
	if not event.is_action('draw') and not event.is_action('pass'):
		return
	#0 = yours
	#1 = theirs
	#2 = nobody
	if game.turn != 0:
		return
	if event.is_action('draw'):
		if event.is_action_pressed('draw'):
			$Node.circle.expand()
			sounds.mouse_tap()
			
		advance_draw_step()
	elif event.is_action('pass'):
		if event.is_action_pressed('pass'):
			$Node.circle.expand()
			sounds.mouse_tap()
		advance_pass_step()
func draw_card():
	var packet = Packet.new()
	packet.event = 'draw'
	Client.socket.send_text(packet.stringify())
func pass_turn():
	var packet = Packet.new()
	packet.event = 'pass'
	Client.socket.send_text(packet.stringify())
