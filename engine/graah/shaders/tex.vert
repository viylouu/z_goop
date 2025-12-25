#version 430 core

const vec2 verts[6] = vec2[6](
    vec2(0,0), vec2(0,1), vec2(1,1),
    vec2(1,1), vec2(1,0), vec2(0,0)
    );

layout(std140, binding = 0) uniform Rubo {
    vec2 pos;
    vec2 size;
    vec4 col;
    vec4 samp;
    mat4 transf;

    mat4 proj;
} ubo;

out vec2 uv;
out vec4 fCol;
out vec4 fSamp;

void main() {
    vec2 vert = verts[gl_VertexID];
    uv = vert;
    fCol = ubo.col;
    fSamp = ubo.samp;
    gl_Position = ubo.proj * ubo.transf * vec4(vert * ubo.size + ubo.pos, 0,1);
}

