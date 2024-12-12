extends CanvasLayer
@onready var text_scene = load('res://text_scene.tscn')
@onready var texts = $Texts
@onready var mouse = $Node2D
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
		clear_children()
		var node = text_scene.instantiate()
		texts.add_child(node)
		node.text.text = 'Draw?'
		node.float_up()
		mouse.scale = Vector2(.3,.3)
		var tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
	elif draw_step == 4:
		clear_children()
		var node = text_scene.instantiate()
		texts.add_child(node)
		node.text.text = 'Draw!'
		node.float_up()
		reset_timer()
		current_timer = false
		mouse.scale = Vector2(.6,.6)
		var tween = create_tween().tween_property(mouse,'scale',Vector2(1,1),.2)
		reset_draw()
	print('draw step')
	current_timer = timeout(.4)
	current_timer.timeout.connect(reset_draw,CONNECT_ONE_SHOT)
	pass
func clear_children():
	for text in texts.get_children():
		texts.remove_child(text)
		text.queue_free()
func timeout(time:float):
	return get_tree().create_timer(time)
