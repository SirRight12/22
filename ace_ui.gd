extends Control

@export var dictionary:Dictionary[String,Texture2D]

@onready var ace_menu = get_parent().get_parent()


var hovering = false
func set_ace_name(ace_name:String):
	$Content/TextureRect.texture = dictionary[ace_name]
	$Content/SubViewport.text = ace_name
func _ready():
	if not ace_menu.is_in_group('Ace Menu'):
		push_error("Hey bozo, check the parent tree because this ace's parent's parent is not the ace menu")
	hovered.bind()
	mouse_entered.connect(hovered)
	mouse_exited.connect(exited)
	pass
func hovered():
	var mat:ShaderMaterial = $ColorRect.material
	print('hover')
	mat.set_shader_parameter('enabled',true)
	hovering = true
	ace_menu.ace_hovered(self)
	
func exited():
	var mat:ShaderMaterial = $ColorRect.material
	mat.set_shader_parameter('enabled',false)
	hovering = false
	ace_menu.ace_unhover(self)
func _input(event):
	if not hovering:
		return
	if event.is_action_released('draw'):
		ace_menu.ace_click(self)
		pass
