#version 430 core

layout(location = 0) uniform sampler2D tex;

in vec4 fCol;
in vec2 uv;

out vec4 oCol;

void main() {
    vec4 t = texture(tex, uv);
    if (t.a == 0)
        discard;
    oCol = t * fCol;
}

