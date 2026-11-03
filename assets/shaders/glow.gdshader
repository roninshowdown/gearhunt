shader_type canvas_item;
render_mode blend_add;
// Soft additive dot used for particles, materials and magic.

void fragment() {
	float r = length(UV - 0.5) * 2.0;
	float core = smoothstep(0.34, 0.0, r);
	float halo = pow(max(1.0 - r, 0.0), 2.4) * 0.55;
	COLOR = vec4(COLOR.rgb * (halo + core) + vec3(core * 0.6), 1.0) * COLOR.a;
}
