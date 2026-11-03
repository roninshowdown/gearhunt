shader_type canvas_item;
#include "common.gdshaderinc"
// Lasting stain on the floor where an enemy died. INSTANCE_CUSTOM.r = seed.

varying vec4 v_custom;

void vertex() {
	v_custom = INSTANCE_CUSTOM;
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float seed = v_custom.r * 91.0;
	float n = fbm(p * 2.6 + seed);
	float shape = 1.0 - smoothstep(0.42, 0.5, length(p) * (0.72 + n * 0.75));
	float drops = smoothstep(0.73, 0.76, value_noise(p * 8.0 + seed)) * (1.0 - smoothstep(0.5, 0.95, length(p)));
	COLOR.a *= max(shape * (0.5 + n * 0.5), drops * 0.75);
}
