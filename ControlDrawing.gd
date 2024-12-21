extends CanvasLayer
@onready var text_scene = load('res://text_scene.tscn')
@onready var confirm = $"Node/Texts/Confirm"
@onready var accept = $"Node/Texts/Accept"
@onready var mouse = $"Node/Node2D"
var draw_step = 0
var pass_step = 0
func _input(event: InputEvent) -> void:
	if not event.is_action('draw') and not event.is_action('pass'):
		return
	if event.is_action('draw'):
		advance_draw_step()
	elif event.is_action('pass'):
		advance_pass_step()
func reset_draw():
	draw_step = 0
var current_timer = false
func reset_timer():
	if current_timer:
		if len(current_timer.timeout.get_connections()) > 0:
			current_timer.timeout.disconnect(reset_draw)
func advance_draw_step():
	draw_step += 1
	reset_timer()
	if draw_step == 2:
		confirm.words = "draw?"
		accept.hide()
		confirm.float_up()
		mouse.scale = Vector2(.3,.3)
		var _tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
	elif draw_step == 4:
		reset_timer()
		accept.words = "DRAW!"
		confirm.hide()
		accept.float_up()
		CardManager.draw_card()
		current_timer = false
		mouse.scale = Vector2(.6,.6)
		var _tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
		reset_draw()
	print('draw step')
	current_timer = timeout(.4)
	current_timer.timeout.connect(reset_draw,CONNECT_ONE_SHOT)
	pass
func reset_pass():
	pass_step = 0
var pass_timer = null
func advance_pass_step():
	pass_step += 1
	reset_timer()
	if pass_step == 2:
		confirm.words = "pass?"
		accept.hide()
		confirm.float_up()
		mouse.scale = Vector2(.3,.3)
		var _tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
	elif pass_step == 4:
		reset_timer()
		accept.words = "PASS!"
		confirm.hide()
		accept.float_up()
		CardManager.pass_turn()
		current_timer = false
		mouse.scale = Vector2(.6,.6)
		var _tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
		reset_draw()
	print('draw step')
	pass_timer = timeout(.4)
	pass_timer.timeout.connect(reset_pass,CONNECT_ONE_SHOT)
	pass
func timeout(time:float):
	return get_tree().create_timer(time)
