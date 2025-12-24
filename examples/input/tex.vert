#version 430 core

const vec2 verts[6] = vec2[6](
    vec2(-.5,-.5), vec2(-.5,.5), vec2(.5,.5),
    vec2(.5,.5), vec2(.5,-.5), vec2(-.5,-.5)
    );

layout(std140, binding=0) uniform A {
    vec2 pos;
} ubo;

out vec2 uv;

void main() {
    vec2 vert = verts[gl_VertexID];
    uv = vert + vec2(.5);
    uv.y = 1-uv.y;
    gl_Position = vec4(vert + ubo.pos, 0,1);
}
