shader_type spatial;

uniform sampler2D heightMap;

void vertex(){
	float y = texture(heightMap, UV).r;
	VERTEX.y = y;
}

void fragment() {
	ALBEDO = texture(heightMap, UV).xyz;
}
