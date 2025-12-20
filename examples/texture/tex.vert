#version 330 core

const vec2 verts[6] = vec2[6](
    vec2(-.5,-.5), vec2(-.5,.5), vec2(.5,.5),
    vec2(.5,.5), vec2(.5,-.5), vec2(-.5,-.5)
    );

out vec2 uv;

void main() {
    vec2 pos = verts[gl_VertexID];
    uv = pos + vec2(.5);
    gl_Position = vec4(pos, 0,1);
}
