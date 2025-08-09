shader_type canvas_item;

void fragment() {
	vec4 color = texture(TEXTURE,UV);
	color.a = floor(color.a);
	COLOR = color;
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
