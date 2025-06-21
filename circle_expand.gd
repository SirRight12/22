extends ColorRect


func set_radius(val:float):
	var shader_material:ShaderMaterial = material
	shader_material.set_shader_parameter('inner_rad',val)
	pass
func expand():
	self_modulate = Color(1.0,1.0,1.0)
	create_tween().tween_method(set_radius,0.13,.45,.5)
	create_tween().tween_property(self,'self_modulate',Color(1.0,1.0,1.0,0.0),.5)
