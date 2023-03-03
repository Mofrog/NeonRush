shader_type spatial;
render_mode cull_disabled, shadows_disabled, unshaded;

uniform float cell_size = 16;
uniform float cell_spacing = 2;
uniform vec4 line_color : source_color;

varying vec3 v;

void vertex() {
	v = VERTEX;
}

void fragment() {
	ALPHA = 0.05;
	float step_size = cell_size + cell_spacing;
	float ratio = cell_spacing / step_size;
	// Grid
	if (fract(v.x / step_size) < ratio || fract(v.z / step_size) < ratio && v.y == 0.0) {
		ALBEDO = line_color.xyz;
		ALPHA = line_color.q;
	}
}