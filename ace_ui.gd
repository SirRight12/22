extends Control

@export var dictionary:Dictionary[String,Texture2D]
var hovering = false
func set_ace_name(ace_name:String):
	$Content/TextureRect.texture = dictionary[ace_name]
	$Content/SubViewport.text = ace_name
func _ready():
	hovered.bind()
	mouse_entered.connect(hovered)
	mouse_exited.connect(exited)
	pass
func hovered():
	var mat:ShaderMaterial = $ColorRect.material
	print('hover')
	mat.set_shader_parameter('enabled',true)
	hovering = true
	get_parent().get_parent().ace_hovered(self)
func exited():
	var mat:ShaderMaterial = $ColorRect.material
	mat.set_shader_parameter('enabled',false)
	hovering = false
func _input(event):
	if not hovering:
		return
	push_warning('inputted')
	if event.is_action_pressed('draw'):
		push_error('draw')
		pass
