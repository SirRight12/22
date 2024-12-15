shader_type canvas_item;

uniform float outer_radius = 0.0;
uniform float inner_radius = 0.0;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	float dist = sqrt(pow(UV.x - .5,2) + pow(UV.y - .5,2));
	if (dist < inner_radius) {
		COLOR = vec4(1.0,1.0,1.0,0.0);
		discard;
	}
	if (dist > outer_radius) {
		COLOR = vec4(1.0,1.0,1.0,0.0);
		discard;
	}
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
