shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.266, 0.0, 0.266, 1.0); // #440044
uniform float wobble_speed = 2.0;
uniform float wobble_strength = 0.03;
uniform float scale_strength = 0.04;

void fragment() {
	float t = TIME * wobble_speed;

	vec2 uv = UV - vec2(0.5);

	float scale_x = 1.0 + sin(t) * scale_strength;
	float scale_y = 1.0 - sin(t) * scale_strength;

	uv.x /= scale_x;
	uv.y /= scale_y;

	uv.x += sin((uv.y * 8.0) + t * 2.0) * wobble_strength;
	uv.y += cos((uv.x * 8.0) + t * 2.0) * wobble_strength;

	uv += vec2(0.5);

	if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0) {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		COLOR = base_color;
	}
}