extends Sprite2D


func expand():
	var mat:ShaderMaterial = material
	mat.set_shader_parameter('Outer Radius',.3)
	mat.set_shader_parameter('Inner Radius',.3/2.0)
	
