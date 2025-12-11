const zg = @import("z_goop");
const zglfw = @import("z_glfw");
const std = @import("std");

const Game = struct{
    pub fn init() !void {
        std.debug.print("init!\n", .{});
    }

    pub fn update(dt: f32) !void { 
        std.debug.print("update! {d:.2} FPS\n", .{ 1.0/dt });
    }

    pub fn exit() !void {
        std.debug.print("exit!\n", .{});
    }
};

pub fn main() !void {
    try zg.run(.{
        .plat_impl = zglfw.impl,

        .init   = Game.init,
        .update = Game.update,
        .exit   = Game.exit,

        .title  = "window",
        .width  = 800,
        .height = 600
    });
}
