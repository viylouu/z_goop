const std = @import("std");

const zg = @import("z_goop");
const zrend = zg.rend;

const zglfw = @import("z_glfw");
const zgl = @import("z_gl");

const Game = struct{
    pub var r_impl: *zrend.Impl = undefined;

    pub fn init() !void {
        std.debug.print("init!\n", .{});
    }

    pub fn update(dt: f32) !void { 
        std.debug.print("update! {d:.2} FPS\n", .{ 1.0/dt });

        r_impl.clear(.{1,0,1,1});
    }

    pub fn exit() !void {
        std.debug.print("exit!\n", .{});
    }
};

pub fn main() !void {
    Game.r_impl = &zgl.impl;

    try zg.run(.{
        .plat_impl = &zglfw.impl,
        .rend_impl = Game.r_impl,

        .init   = Game.init,
        .update = Game.update,
        .exit   = Game.exit,

        .title  = "window",
        .width  = 800,
        .height = 600,
    });
}
