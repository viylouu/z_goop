#version 430 core

layout(location = 0) uniform sampler2D tex;

in vec4 fCol;
in vec2 uv;
in vec4 fSamp;

out vec4 oCol;

void main() {
    vec4 t = texture(tex, uv * fSamp.zw + fSamp.xy);
    if (t.a == 0)
        discard;
    oCol = t * fCol;
}

