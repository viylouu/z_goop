#version 430 core

const vec2 verts[6] = vec2[6](
    vec2(0,0), vec2(0,1), vec2(1,1),
    vec2(1,1), vec2(1,0), vec2(0,0)
    );

layout(std140, binding = 0) uniform Rubo {
    vec2 pos;
    vec2 size;
    vec4 col;
    mat4 transf;

    mat4 proj;
} ubo;

out vec4 fCol;

void main() {
    vec2 vert = verts[gl_VertexID];
    fCol = ubo.col;
    gl_Position = ubo.proj * ubo.transf * vec4(vert * ubo.size + ubo.pos, 0,1);
}
