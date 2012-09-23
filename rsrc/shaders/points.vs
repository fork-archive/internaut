#version 150

/*
in int gl_VertexID;
in int gl_InstanceID;
in vec4 gl_Color;
in vec4 gl_SecondaryColor;
in vec3 gl_Normal;
in vec4 gl_Vertex;
in vec4 gl_MultiTexCoord{0-7};
in float gl_FogCoord;

out gl_PerVertex {
vec4 gl_Position;
float gl_PointSize;
float gl_ClipDistance[];
vec4 gl_ClipVertex; 
}; 

out vec4 gl_FrontColor;
out vec4 gl_BackColor;
out vec4 gl_FrontSecondaryColor;
out vec4 gl_BackSecondaryColor;
out vec4 gl_TexCoord[];
out float gl_FogFragCoord;
*/

in vec3 in_position;
in vec3 in_color;

out vec3 color;

uniform mat4 projectionmatrix;
uniform mat4 modelviewmatrix;

void main() {
    //gl_Position = projectionmatrix * modelviewmatrix * 
    //gl_Position =  gl_ProjectionMatrix * gl_ModelViewMatrix * vec4(in_position, 1.0);
    //gl_Position = projectionmatrix * modelviewmatrix * vec4(in_position, 1.0);
    gl_Position =  projectionmatrix * modelviewmatrix * vec4(in_position, 1.0);

	 //color = vec4(in_color, 1.0);
}
