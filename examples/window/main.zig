const zg = @import("z_goop");

const std = @import("std");

const game = struct{
    fn init() !void {
        std.debug.print("init!\n", .{});
    }

    fn update(dt: f32) !void { 
        std.debug.print("update! {d} FPS\n", .{ 1.0/dt });
    }

    fn exit() !void {
        std.debug.print("exit!\n", .{});
    }
};

pub fn main() !void {
    try zg.run(.{
        .init   = game.init,
        .update = game.update,
        .exit   = game.exit,

        .title  = "window",
        .width  = 800,
        .height = 600
    });
}
