shader_type canvas_item;

void fragment() {
	float noise = texture(TEXTURE, UV).r; 
	if (noise > 0.75){
		COLOR = vec4(noise, 0.0, 0.0, 1.0);
	} else if (noise > 0.5){
		COLOR = vec4(0.0, noise, 0.0, 1.0);
	} else {
		COLOR = vec4(0.0, 0.0, noise, 1.0);
	}
}