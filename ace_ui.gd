extends Control

@export var dictionary:Dictionary[String,Texture2D]
var hovering = false
func set_ace_name(ace_name:String):
	$TextureRect.texture = dictionary[ace_name]
	$AutoSizeLabel.text = ace_name.replace('-',' ')
func _ready():
	hovered.bind()
	mouse_entered.connect(hovered)
	mouse_exited.connect(exited)
	pass
func hovered():
	hovering = true
	get_parent().get_parent().ace_hovered(self)
	pass
func exited():
	hovering = false
func _input(event):
	if not hovering:
		return
	push_warning('inputted')
	if event.is_action_pressed('draw'):
		push_error('draw')
		pass
