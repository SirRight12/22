extends CanvasLayer
@onready var text_scene = load('res://text_scene.tscn')
@onready var draw_q = $"Texts/Draw?"
@onready var draw_a = $"Texts/Draw!"
@onready var mouse = $"Node2D"
var draw_step = 0
func _input(event: InputEvent) -> void:
	if not event.is_action('draw'):
		return
	if event.is_action('draw'):
		advance_draw_step()
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
		draw_a.hide()
		draw_a.reset()
		draw_q.show()
		draw_q.reset()
		draw_q.float_up()
		mouse.scale = Vector2(.3,.3)
		var tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
	elif draw_step == 4:
		reset_timer()
		draw_q.hide()
		draw_q.reset()
		draw_a.show()
		draw_a.reset()
		draw_a.float_up()
		current_timer = false
		mouse.scale = Vector2(.6,.6)
		var tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
		reset_draw()
	print('draw step')
	current_timer = timeout(.4)
	current_timer.timeout.connect(reset_draw,CONNECT_ONE_SHOT)
	pass
func timeout(time:float):
	return get_tree().create_timer(time)
