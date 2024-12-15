shader_type canvas_item;

uniform float outer_radius : hint_range(0.0, 500.0);
uniform float inner_radius : hint_range(0.0, 500.0);

void fragment() {
    FRAGCOORD.xy;
	discard;
}
