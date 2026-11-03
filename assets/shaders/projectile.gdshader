shader_type canvas_item;
render_mode blend_add;
// Comet: bright head at +X, tail fading towards -X.

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float along = (p.x + 1.0) * 0.5;
	float width = mix(0.04, 0.46, pow(along, 2.0));
	float body = smoothstep(width, width * 0.2, abs(p.y)) * smoothstep(0.0, 0.25, along) * smoothstep(1.0, 0.92, along);
	float head = smoothstep(0.46, 0.0, length(p - vec2(0.62, 0.0)));
	vec3 color = COLOR.rgb * body * (0.35 + along) + vec3(1.0) * head * 0.9;
	COLOR = vec4(color, 1.0) * COLOR.a;
}
