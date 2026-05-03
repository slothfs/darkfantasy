shader_type canvas_item;

uniform float move_speed = 2.0;
uniform float move_strength = 12.0; // how much it moves up/down

void vertex() {
	float t = TIME * move_speed;

	// smooth up and down movement
	VERTEX.y += sin(t) * move_strength;
}

void fragment() {
	COLOR = texture(TEXTURE, UV) * COLOR;
}
