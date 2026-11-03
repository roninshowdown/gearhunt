shader_type canvas_item;
#include "common.gdshaderinc"
// Sea floor lit by moving caustics, bordered by a glowing reef.

uniform vec3 color_a;
uniform vec3 color_b;
uniform vec3 color_c;
uniform vec2 arena_half = vec2(1000.0, 620.0);
uniform vec2 world_origin = vec2(-4000.0, -3000.0);
uniform vec2 world_size = vec2(8000.0, 6000.0);

varying vec2 world;

void vertex() {
	world = world_origin + UV * world_size;
}

float caustics(vec2 p, float time) {
	vec2 q = p;
	float c = 1.0;
	float intensity = 0.005;
	for (int n = 0; n < 4; n++) {
		float t = time * (1.0 - 3.5 / float(n + 1));
		q = p + vec2(cos(t - q.x) + sin(t + q.y), sin(t - q.y) + cos(t + q.x));
		c += 1.0 / length(vec2(p.x / (sin(q.x + t) / intensity), p.y / (cos(q.y + t) / intensity)));
	}
	c /= 4.0;
	c = 1.17 - pow(c, 1.4);
	return pow(abs(c), 8.0);
}

void fragment() {
	float time = TIME * 0.45;
	float d = arena_distance(world, arena_half, TIME);

	float sand = fbm(world * 0.0035);
	float ripples = sin(world.y * 0.018 + sand * 9.0 + world.x * 0.006) * 0.5 + 0.5;
	vec3 floor_color = mix(color_a, color_b, smoothstep(0.25, 0.8, sand) * 0.75 + ripples * 0.1);
	floor_color *= 0.92 + 0.16 * fbm(world * 0.02);

	// Dark algae patches and pale pebbles give the floor something to read.
	float algae = smoothstep(0.56, 0.68, fbm(world * 0.0065 + 40.0));
	floor_color = mix(floor_color, color_a * 0.72, algae * 0.55);
	vec2 cell = floor(world / 150.0);
	vec2 local = fract(world / 150.0) - 0.5 - (hash22(cell) - 0.5) * 0.6;
	float pebble = (1.0 - smoothstep(0.03, 0.05, length(local) / (0.4 + hash21(cell)))) * step(0.68, hash21(cell + 3.0));
	floor_color = mix(floor_color, color_b * 1.5, pebble * 0.45);

	float light = caustics(mod(world * 0.0042, 6.2831) - 250.0, time);
	vec3 inside = floor_color + color_c * clamp(light, 0.0, 1.0) * 0.34;

	// Outside the arena: abyss with distant, drifting light.
	float abyss = fbm(world * 0.0016 + vec2(0.0, time * 0.3));
	vec3 outside = mix(color_a * 0.22, color_a * 0.8, abyss);

	vec3 color = mix(inside, outside, smoothstep(-1.5, 1.5, d));
	float shade = smoothstep(-130.0, 0.0, d) * (1.0 - smoothstep(0.0, 1.0, d));
	color *= 1.0 - shade * 0.5;

	float reef = 1.0 - smoothstep(0.0, 12.0, abs(d - 4.0));
	float beads = 0.6 + 0.4 * sin((world.x + world.y) * 0.05 + TIME * 1.5);
	color += color_c * reef * beads * 0.9;
	color += color_c * exp(-max(d, 0.0) * 0.015) * step(0.0, d) * 0.2;
	COLOR = vec4(color, 1.0);
}
