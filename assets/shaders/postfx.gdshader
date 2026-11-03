shader_type canvas_item;
// Final screen pass: soft bloom, slight colour fringe, vignette, damage tint.

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;
uniform float damage_flash = 0.0;
uniform float bloom = 0.5;

void fragment() {
	vec2 uv = SCREEN_UV;
	vec2 from_center = uv - 0.5;
	float fringe = dot(from_center, from_center) * 0.0035;
	vec3 color;
	color.r = texture(screen_texture, uv + from_center * fringe).r;
	color.g = texture(screen_texture, uv).g;
	color.b = texture(screen_texture, uv - from_center * fringe).b;

	vec3 wide = textureLod(screen_texture, uv, 3.0).rgb * 0.5 + textureLod(screen_texture, uv, 5.0).rgb * 0.5;
	color += max(wide - 0.42, vec3(0.0)) * bloom;

	float vignette = smoothstep(0.92, 0.32, length(from_center * vec2(1.0, 0.82)));
	color *= mix(0.6, 1.0, vignette);
	color = mix(color, vec3(0.9, 0.05, 0.06), damage_flash * (1.0 - vignette * 0.8) * 0.6);
	COLOR = vec4(color, 1.0);
}
