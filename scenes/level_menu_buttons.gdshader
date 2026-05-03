shader_type canvas_item;

uniform int state = 0;

uniform float speed = 2.0;
uniform float split_y = 0.5;

// movement
uniform float hover_amount = 1.5;
uniform float press_amount = 10.0;

// tear
uniform float gap_size = 0.05;
uniform float tooth_strength = 0.02;
uniform float tooth_density = 90.0;

// glow
uniform vec4 glow_color : source_color = vec4(0.6, 0.2, 1.0, 1.0);
uniform float glow_strength = 1.5;

float hash(float x) {
	return fract(sin(x) * 43758.5453);
}

void vertex() {
	vec2 pos = VERTEX;

	float t = TIME * speed;
	float anim = sin(t) * 0.5 + 0.5;

	float move = 0.0;

	if (state == 1) {
		move = anim * hover_amount;
	} else if (state == 2) {
		move = anim * press_amount;
	}

	if (state != 0) {
		if (UV.y < split_y) {
			pos += vec2(-move, -move * 0.2);
		} else {
			pos += vec2(move, move * 0.2);
		}
	}

	VERTEX = pos;
}

void fragment() {
	vec2 uv = UV;
	float t = TIME * speed;

	vec4 col = texture(TEXTURE, uv) * COLOR;

	float dist = abs(uv.y - split_y);

	// ---------------- NORMAL ----------------
	if (state == 0) {
		col = texture(TEXTURE, uv) * COLOR;
	}

	// ---------------- HOVER ----------------
	else if (state == 1) {
		if (dist < gap_size * 0.4) {
			float glow = sin(t * 4.0) * 0.5 + 0.5;
			col.rgb += glow * 0.08;
		}
	}

	// ---------------- PRESSED ----------------
	else if (state == 2) {

		if (dist < gap_size) {
			float pulse = sin(t * 6.0) * 0.5 + 0.5;
			float glow = (1.0 - dist / gap_size);

			col = glow_color * glow * glow_strength * pulse;
		}
		else {
			float edge = smoothstep(gap_size, 0.0, dist);

			float tooth =
				hash(uv.x * tooth_density + t * 2.0) - 0.5;

			uv.x += tooth * tooth_strength * edge;

			col = texture(TEXTURE, uv) * COLOR;

			float dark = smoothstep(gap_size * 2.5, gap_size, dist);
			col.rgb *= (1.0 - dark * 0.3);
		}
	}

	COLOR = col;
}