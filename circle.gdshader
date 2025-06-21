shader_type canvas_item;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

uniform float inner_rad = 0.45;

void fragment() {
	float outer_rad = inner_rad + .05;
	vec2 offset = vec2(.5,.5);
	float radius = sqrt(pow(UV.x-offset.x,2) + pow(UV.y-offset.y,2));
	if (radius > outer_rad) {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
	if (radius > 0.0 && radius < inner_rad) {
		COLOR = vec4(0.0,0.0,0.0,0.0);
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
