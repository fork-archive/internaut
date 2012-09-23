#version 150

layout(points) in;
layout(points, max_vertices = 36) out;

/*
in gl_PerVertex {
    vec4  gl_Position;
    float gl_PointSize;
    float gl_ClipDistance[];
} gl_in[];

in int gl_PrimitiveIDIn;
// only for OpenGL 4.0+
in int gl_InvocationID;

out gl_PerVertex {
    vec4  gl_Position;
    float gl_PointSize;
    float gl_ClipDistance[];
};

out int gl_PrimitiveID;
out int gl_Layer;
// only for OpenGL 4.1+
out int gl_ViewportIndex;
*/

uniform mat4 projectionmatrix;
uniform mat4 modelviewmatrix;
uniform float gridradius;

varying in vec3 pos;
void main()
{
  for(int i = 0; i < gl_VerticesIn; i++)
  {
	gl_Position = projectionmatrix * modelviewmatrix*gl_in[i].gl_Position.xyzw;
    EmitVertex();
}
/*
	mat4 projectionmodelviewmatrix = projectionmatrix * modelviewmatrix;

  for(int i = 0; i < gl_VerticesIn; i++)
  {
	vec4 A = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(-gridradius,gridradius,gridradius,0));
	vec4 B = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(gridradius,gridradius,gridradius,0));
	vec4 C = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(-gridradius,gridradius,-gridradius,0));
	vec4 D = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(gridradius,gridradius,-gridradius,0));
	vec4 E = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(-gridradius,-gridradius,gridradius,0));
	vec4 F = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(gridradius,-gridradius,gridradius,0));
	vec4 G = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(-gridradius,-gridradius,-gridradius,0));
	vec4 H = projectionmodelviewmatrix * (gl_in[i].gl_Position.xyzw + vec4(gridradius,-gridradius,-gridradius,0));

	gl_Position = C;
    EmitVertex();
	gl_Position = D;
    EmitVertex();
	gl_Position = G;
    EmitVertex();
    EndPrimitive();

	gl_Position = G;
    EmitVertex();
	gl_Position = D;
    EmitVertex();
	gl_Position = H;
    EmitVertex();
    EndPrimitive();

	gl_Position = H;
    EmitVertex();
	gl_Position = D;
    EmitVertex();
	gl_Position = B;
    EmitVertex();
    EndPrimitive();

	gl_Position = B;
    EmitVertex();
	gl_Position = H;
    EmitVertex();
	gl_Position = F;
    EmitVertex();
    EndPrimitive();

	gl_Position = F;
    EmitVertex();
	gl_Position = B;
    EmitVertex();
	gl_Position = A;
    EmitVertex();
    EndPrimitive();

	gl_Position = A;
    EmitVertex();
	gl_Position = F;
    EmitVertex();
	gl_Position = E;
    EmitVertex();
    EndPrimitive();

	gl_Position = E;
    EmitVertex();
	gl_Position = F;
    EmitVertex();
	gl_Position = H;
    EmitVertex();
    EndPrimitive();

	gl_Position = H;
    EmitVertex();
	gl_Position = E;
    EmitVertex();
	gl_Position = G;
    EmitVertex();
    EndPrimitive();

	gl_Position = G;
    EmitVertex();
	gl_Position = E;
    EmitVertex();
	gl_Position = C;
    EmitVertex();
    EndPrimitive();

	gl_Position = C;
    EmitVertex();
	gl_Position = E;
    EmitVertex();
	gl_Position = A;
    EmitVertex();
    EndPrimitive();

	gl_Position = A;
    EmitVertex();
	gl_Position = C;
    EmitVertex();
	gl_Position = D;
    EmitVertex();
    EndPrimitive();

	gl_Position = D;
    EmitVertex();
	gl_Position = A;
    EmitVertex();
	gl_Position = B;
    EmitVertex();
    EndPrimitive();
	}
*/
}