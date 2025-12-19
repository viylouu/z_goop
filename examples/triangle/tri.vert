#version 330 core

const vec2 verts[3] = vec2[3](
    vec2(0,.5), vec2(-.5,-.5), vec2(.5,-.5)
    );

void main() {
    vec2 pos = verts[gl_VertexID];
    gl_Position = vec4(pos, 0,1);
}
