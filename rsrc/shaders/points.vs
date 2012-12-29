#version 130

in vec3 in_position;

in vec2 in_coord;
out vec2 out_coord;

uniform mat4 projectionmatrix;
uniform mat4 modelviewmatrix;

void main() {
    gl_Position =  projectionmatrix * modelviewmatrix * vec4(in_position, 1.0);
    out_coord = in_coord;
	}
