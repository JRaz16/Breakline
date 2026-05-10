shader_type spatial;

render_mode unshaded, blend_add;

uniform vec4 glow_color : source_color = vec4(1, 0.6, 0.2, 0.3);
uniform float intensity = 2.0;

void fragment() {
	ALBEDO = glow_color.rgb * intensity;
	EMISSION = glow_color.rgb * intensity;
}