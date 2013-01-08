#version 130

in vec2 out_coord;
in vec3 out_color;

uniform sampler2D tex;

uniform bool color;
 
void main()
{
	if(!color)
	    gl_FragColor = texture2D(tex,out_coord);
	else
		gl_FragColor = vec4(out_color,1.0);
}
