#version 130

in vec2 out_coord;

uniform sampler2D tex;
 
void main()
{
    gl_FragColor = texture2D(tex,out_coord);
}
