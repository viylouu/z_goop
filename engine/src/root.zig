const std = @import("std");
pub const plat = @import("plat.zig");
pub const rend = @import("rend.zig");

pub fn run(api: struct{
    plat_impl: *plat.Impl,
    rend_impl: *rend.Impl,

    init:   fn()        anyerror !void,
    update: fn(dt: f32) anyerror !void,
    exit:   fn()        anyerror !void,

    title:  [:0]const u8,
    width:  u32,
    height: u32,
}) !void {
    try api.plat_impl.make(api.rend_impl, api.width,api.height, api.title);
    try api.rend_impl.make(api.plat_impl);

    try api.init();

    while (!try api.plat_impl.is_closed()) {
        try api.plat_impl.poll();

        try api.update(1.0/60.0);

        try api.plat_impl.swap();
    }

    try api.exit();

    try api.rend_impl.delete();
    try api.plat_impl.delete();
}
