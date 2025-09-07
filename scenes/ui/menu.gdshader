shader_type canvas_item;

// how fast the static changes
uniform float speed = 3.0;

// brightness of static
uniform float intensity = 0.3;

// random number generator
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
    // Use UV (0–1 across the rect)
    float noise = rand(UV * TIME * speed);
    COLOR = vec4(vec3(noise * intensity), 1.0);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
