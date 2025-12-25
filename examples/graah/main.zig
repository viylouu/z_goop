const std = @import("std");

const zg = @import("z_goop");
const zrend = zg.rend;
const zmath = zg.math;
const Vec2 = zmath.Vec2;
const Vec4 = zmath.Vec4;

const gr = @import("graah");

const zglfw = @import("z_glfw");
const zgl = @import("z_gl");

// NOTE: the following code is ONLY differently structured from the other examples due to the fact that you can. you do not need to use graah like this, or non graah like this even.

pub fn main() !void {
    state.r = &zgl.impl;

    try zg.run(.{
        .plat_impl = &zglfw.impl,
        .rend_impl = state.r,

        .title = "graah",
        .width = 800,
        .height = 600,

        .init = init,
        .update = update,
        .exit = exit,
    });
}

var state: struct{
    r: *zrend.Impl = undefined,
    tex: gr.Texture = undefined,
    fb: gr.Framebuffer = undefined,
} = .{};

pub fn init() !void {
    try gr.init(.{
        .rend_impl = state.r,
    });

    state.tex = try gr.make_tex(@embedFile("tex.png"));

    state.fb = try gr.make_fb(320,180);
}

pub fn exit() void {
    state.tex.delete();
    state.fb.delete();
    gr.deinit();
}

pub fn update(dt: f32) !void {
    gr.clear(0.2, 0.4, 0.3, 1, null);
    gr.clear(0,0,0,0, &state.fb);
    gr.rect(.{ 
        .pos = Vec2{.x=dt*1000, .y=0},
        .size = Vec2{.x=500, .y=500}, 
        .col = Vec4{.x=1, .y=0, .z=0.5, .w=1},
    });

    gr.tex(.{
        .pos = Vec2{.x=64,.y=64},
        .size = Vec2{.x=32, .y=32},
        .col = Vec4{.x=0,.y=0,.z=1,.w=1},
        .tex = &state.tex,
        .targ = &state.fb,
    });

    gr.fb(.{
        .in = &state.fb,
    });
}
