shader_type canvas_item;

uniform vec4 color;
uniform float border_left = 0.0;
uniform float border_right = 1.0;
uniform float border_top = 0.0;
uniform float border_bottom = 1.0;
uniform bool enabled = true;

void fragment() {
	if (enabled) {
		if (UV.x < border_left) {
			COLOR = color;
		}
		if (UV.x > border_right) {
			COLOR = color;
		}
		if (UV.y < border_top) {
			COLOR = color;
		}
		if (UV.y > border_bottom) {
			COLOR = color;
		}
	}
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
