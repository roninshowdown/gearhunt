float hash21(vec2 p) {
	p = fract(p * vec2(123.34, 456.21));
	p += dot(p, p + 45.32);
	return fract(p.x * p.y);
}

vec2 hash22(vec2 p) {
	float n = hash21(p);
	return vec2(n, hash21(p + n + 17.1));
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash21(i), hash21(i + vec2(1, 0)), f.x), mix(hash21(i + vec2(0, 1)), hash21(i + vec2(1, 1)), f.x), f.y);
}

float fbm(vec2 p) {
	float value = 0.0;
	float amplitude = 0.5;
	for (int i = 0; i < 4; i++) {
		value += amplitude * value_noise(p);
		p = p * 2.03 + vec2(13.7, 7.1);
		amplitude *= 0.5;
	}
	return value;
}

// Distance to a rounded box centred on the origin; negative inside.
float rounded_box(vec2 p, vec2 half_size, float corner) {
	vec2 q = abs(p) - half_size + corner;
	return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - corner;
}

// Arena border with an organic, slowly moving outline.
float arena_distance(vec2 world, vec2 half_size, float time) {
	float wobble = (fbm(world * 0.006 + vec2(time * 0.05, 0.0)) - 0.5) * 46.0;
	return rounded_box(world, half_size, 90.0) + wobble;
}
