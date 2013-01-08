#version 130

in vec3 in_position;
in vec2 in_coord;
in int in_index;
in vec3 in_norm;
in vec3 in_color;

out vec2 out_coord;
out vec3 out_color;

uniform mat4 projectionmatrix;
uniform mat4 modelviewmatrix;

uniform bool gui;

void main() {
	if(!gui)
   		gl_Position =  projectionmatrix * modelviewmatrix * vec4(in_position, 1.0);
    else
    	gl_Position =  vec4(in_position, 1.0);
    out_coord = in_coord;
    out_color = in_color;
	}
