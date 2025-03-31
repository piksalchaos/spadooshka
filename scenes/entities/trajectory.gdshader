shader_type spatial;

render_mode cull_disabled;

uniform float a;
uniform float b;
uniform float c;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX.y = VERTEX.x * (a * VERTEX.x + b) + c;
}

void fragment() {
	ALBEDO = vec3(1, 0, 0);
	ALPHA = 0.2;
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
