const std = @import("std");

pub fn run(api: struct{
    init:   fn()        anyerror !void,
    update: fn(dt: f32) anyerror !void,
    exit:   fn()        anyerror !void,

    title:  []const u8,
    width:  u32,
    height: u32,
}) !void {
    try api.init();

    try api.update(1.0/60.0);

    try api.exit();
}
