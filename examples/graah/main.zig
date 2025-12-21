const std = @import("std");

const zg = @import("z_goop");
const zrend = zg.rend;

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
} = .{};

pub fn init() !void {
    try gr.init(.{
        .rend_impl = state.r,
    });
}

pub fn exit() void {
    gr.deinit();
}

pub fn update(dt: f32) !void {
    _ = dt;
}
