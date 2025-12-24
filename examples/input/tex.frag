#version 430 core

layout(location = 0) uniform sampler2D u_tex;

in vec2 uv;

out vec4 oCol;

void main() {
    oCol = texture(u_tex, uv);
}
