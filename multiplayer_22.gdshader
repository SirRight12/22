shader_type spatial;

render_mode unshaded;

uniform sampler2D sample_texture : filter_nearest_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;
uniform vec4 emission_color : source_color = vec4(1.0, 0.2, 0.5, 1.0);
uniform float strength = 2.0;

void fragment() {
    vec4 albedo_tex = texture(sample_texture, UV);
	if (albedo_tex.rgb == vec3(1.0)) {
		ALBEDO = vec3(0,1.0,0.0);
	}
    ALBEDO = albedo_tex.rgb;
    EMISSION = emission_color.rgb * albedo_tex.a * strength;
}
