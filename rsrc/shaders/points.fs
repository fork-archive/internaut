#version 130

/*
in vec4 gl_FragCoord;
in bool gl_FrontFacing;
in float gl_ClipDistance[];
in vec2 gl_PointCoord;
in int gl_PrimitiveID;
out float gl_FragDepth;
*/

in vec3 color;
out vec4 colorOut;
 
void main()
{
    //colorOut = vec4(color, 1.0);
    colorOut = vec4(0.25, 0.5, 0.75, 1.0);
}
