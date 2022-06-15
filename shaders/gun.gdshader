shader_type spatial;
uniform sampler2D noise;

void fragment() {
	float temp = texture(noise, vec2(UV.x, UV.y - TIME)).x;
	ALBEDO = vec3(UV, temp);
}
