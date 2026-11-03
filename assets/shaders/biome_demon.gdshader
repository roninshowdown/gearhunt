shader_type canvas_item;
#include "common.gdshaderinc"
// Basalt tiles with lava in the seams, floating in a burning void.

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

// Returns (distance to the nearest seam, random cell id).
vec2 voronoi(vec2 p) {
	vec2 cell = floor(p);
	vec2 local = fract(p);
	vec2 nearest_offset = vec2(0.0);
	vec2 nearest_vector = vec2(0.0);
	float nearest = 8.0;
	for (int y = -1; y <= 1; y++) {
		for (int x = -1; x <= 1; x++) {
			vec2 offset = vec2(float(x), float(y));
			vec2 v = offset + hash22(cell + offset) - local;
			float dist = dot(v, v);
			if (dist < nearest) {
				nearest = dist;
				nearest_vector = v;
				nearest_offset = offset;
			}
		}
	}
	float seam = 8.0;
	for (int y = -2; y <= 2; y++) {
		for (int x = -2; x <= 2; x++) {
			vec2 offset = nearest_offset + vec2(float(x), float(y));
			vec2 v = offset + hash22(cell + offset) - local;
			if (dot(nearest_vector - v, nearest_vector - v) > 0.00001) {
				seam = min(seam, dot(0.5 * (nearest_vector + v), normalize(v - nearest_vector)));
			}
		}
	}
	return vec2(seam, hash21(cell + nearest_offset));
}

void fragment() {
	float d = arena_distance(world, arena_half, TIME * 0.6);
	vec2 warped = world * 0.0075 + (vec2(fbm(world * 0.004), fbm(world * 0.004 + 9.0)) - 0.5) * 1.1;
	vec2 tiles = voronoi(warped);

	vec3 stone = mix(color_a, color_b, tiles.y * 0.55 + 0.45 * fbm(world * 0.02));
	stone *= 0.8 + 0.4 * fbm(world * 0.035);
	stone += color_b * smoothstep(0.34, 0.1, tiles.x) * 0.18;

	float flow = fbm(world * 0.006 + vec2(TIME * 0.1, -TIME * 0.07));
	float pulse = 0.65 + 0.35 * sin(TIME * 1.3 + flow * 9.0);
	// Only some seams carry lava; the rest stay dark so enemies remain readable.
	float molten = smoothstep(0.42, 0.62, fbm(world * 0.0032 + 21.0));
	float seam = 1.0 - smoothstep(0.008, 0.042, tiles.x);
	float seam_glow = exp(-tiles.x * 15.0);
	vec3 inside = mix(stone, color_a * 0.25, seam * 0.85);
	inside = mix(inside, color_c * (0.75 + flow * 0.5), seam * pulse * molten * 0.85);
	inside += color_c * seam_glow * 0.16 * pulse * molten;

	float smoke = fbm(world * 0.0016 + vec2(TIME * 0.03, TIME * 0.08));
	vec3 outside = mix(color_a * 0.3, color_c * 0.28, smoothstep(0.42, 0.85, smoke));

	vec3 color = mix(inside, outside, smoothstep(-1.5, 1.5, d));
	float shade = smoothstep(-110.0, 0.0, d) * (1.0 - smoothstep(0.0, 1.0, d));
	color *= 1.0 - shade * 0.58;
	float rim = 1.0 - smoothstep(0.0, 10.0, abs(d - 3.0));
	color += color_c * rim * (0.6 + 0.4 * sin(world.x * 0.03 - TIME * 2.0));
	COLOR = vec4(color, 1.0);
}
