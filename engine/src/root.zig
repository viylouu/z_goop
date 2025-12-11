const std = @import("std");
pub const plat = @import("plat.zig");

pub fn run(api: struct{
    plat_impl: plat.Impl,

    init:   fn()        anyerror !void,
    update: fn(dt: f32) anyerror !void,
    exit:   fn()        anyerror !void,

    title:  []const u8,
    width:  u32,
    height: u32,
}) !void {
    try api.plat_impl.make();

    try api.init();

    while (!try api.plat_impl.is_closed()) {
        try api.update(1.0/60.0);
    }

    try api.exit();

    try api.plat_impl.delete();
}
