
@tool

extends TextureRect

@onready var mat:ShaderMaterial = self.material
var val = 0
func _process(delta: float) -> void:
	mat.set_shader_parameter('red_displacement',abs(.5 * sin(val) + .5))
	mat.set_shader_parameter('green_displacement',abs(sin(val+PI)))
	mat.set_shader_parameter('intensity',cos(val*4))
	val += delta
	pass
