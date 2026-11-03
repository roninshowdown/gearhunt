shader_type canvas_item;
render_mode blend_premul_alpha;
// Procedural soft-bodied creature. Every enemy type and hero is this shader
// with different parameters (see CreatureLook). The creature faces +X.
// INSTANCE_CUSTOM: r = random phase, g = hit flash, b = spawn telegraph.

uniform vec3 body_color = vec3(0.5, 0.8, 0.6);
uniform vec3 dark_color = vec3(0.1, 0.25, 0.2);
uniform vec3 accent_color = vec3(1.0, 0.9, 0.5);
uniform float lobes = 5.0;
uniform float lobe_amount = 0.06;
uniform float spikes = 0.0;
uniform float spike_length = 0.0;
uniform float eyes = 2.0;
uniform float organelles = 0.5;
uniform float wobble_speed = 2.0;
uniform float flash_override = 0.0;
uniform float phase_override = 0.0;

const float BODY = 0.62;

varying vec4 v_custom;

void vertex() {
	v_custom = INSTANCE_CUSTOM;
}

float disc(vec2 p, vec2 center, float radius, float aa) {
	return 1.0 - smoothstep(radius - aa, radius + aa, length(p - center));
}

void fragment() {
	vec2 p = (UV - 0.5) * 2.0;
	float phase = (v_custom.r + phase_override) * 6.2831;
	float t = TIME * wobble_speed + phase;
	float angle = atan(p.y, p.x);
	float r = length(p);
	float aa = max(fwidth(r), 0.002) * 1.2;

	float edge = BODY * (1.0 + lobe_amount * sin(lobes * angle + t) + 0.035 * sin(3.0 * angle - t * 1.6) + 0.02 * sin(7.0 * angle + t * 0.7));
	if (spikes > 0.5) {
		edge += spike_length * BODY * pow(0.5 + 0.5 * cos(spikes * angle + t * 0.25), 5.0);
	}
	float distance_to_edge = r - edge;
	float body = 1.0 - smoothstep(-aa, aa, distance_to_edge);
	float depth = clamp(r / edge, 0.0, 1.0);

	// Soft volume: dark at the rim, lit from one side like a translucent cell.
	vec3 color = mix(body_color, dark_color, pow(depth, 2.6) * 0.9);
	color += body_color * 0.32 * smoothstep(0.55, -0.45, p.y + p.x * 0.3) * (1.0 - depth * 0.6);

	// Organelles drifting inside the body.
	for (int i = 0; i < 6; i++) {
		float fi = float(i);
		vec2 center = vec2(sin(t * 0.31 + fi * 2.4 + phase), cos(t * 0.27 + fi * 1.7 + phase * 1.3)) * BODY * (0.28 + 0.1 * fi);
		float radius = 0.045 + 0.022 * mod(fi, 3.0);
		float dot_mask = disc(p, center, radius, aa) * step(fi / 6.0, organelles);
		color = mix(color, mix(accent_color, body_color, 0.35), dot_mask * 0.55);
	}

	// Nucleus.
	vec2 nucleus = vec2(-0.14, 0.04) + 0.03 * vec2(sin(t * 0.8), cos(t * 0.6));
	float nucleus_mask = disc(p, nucleus, 0.17, 0.05);
	color = mix(color, dark_color * 0.9 + accent_color * 0.3, nucleus_mask * 0.75);
	color += accent_color * 0.5 * disc(p, nucleus + vec2(-0.04, -0.04), 0.06, 0.05);

	// Glossy membrane and dark outline.
	float membrane = smoothstep(0.72, 0.9, depth) * (1.0 - smoothstep(0.93, 1.0, depth));
	color = mix(color, accent_color, membrane * 0.5);
	color = mix(color, dark_color * 0.28, smoothstep(edge - 0.05, edge - 0.015, r));
	float highlight = disc(p, vec2(-0.2, -0.3), 0.11, 0.09) * (1.0 - depth * 0.3);
	color = mix(color, vec3(1.0), highlight * 0.42);

	// Eyes look towards +X.
	if (eyes > 0.5) {
		for (int i = 0; i < int(eyes); i++) {
			float spread = eyes < 1.5 ? 0.0 : (float(i) / (eyes - 1.0) - 0.5) * 0.52;
			vec2 eye = vec2(0.27 - abs(spread) * 0.2, spread);
			float size = eyes < 1.5 ? 0.15 : 0.105;
			color = mix(color, dark_color * 0.2, disc(p, eye, size + 0.02, aa));
			color = mix(color, vec3(0.97, 0.97, 0.9), disc(p, eye, size, aa));
			color = mix(color, vec3(0.03), disc(p, eye + vec2(size * 0.32, 0.0), size * 0.56, aa));
			color = mix(color, vec3(1.0), disc(p, eye + vec2(size * 0.12, -size * 0.32), size * 0.2, aa));
		}
	}

	color = mix(color, vec3(1.0), max(v_custom.g, flash_override));

	float spawning = v_custom.b;
	float visibility = 1.0 - spawning;
	float glow = exp(-max(distance_to_edge, 0.0) * 8.0) * 0.26 * (1.0 - body);
	vec4 result = vec4(color * body * COLOR.rgb + accent_color * glow, body) * visibility;

	if (spawning > 0.001) {
		float ring = 1.0 - smoothstep(0.0, 0.05, abs(r - (0.28 + 0.5 * spawning)));
		float pulse = 0.55 + 0.45 * sin(TIME * 18.0);
		result.rgb += accent_color * ring * pulse * 0.8;
	}
	COLOR = result;
}
