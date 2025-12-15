const std = @import("std");
pub const plat = @import("plat.zig");
pub const rend = @import("rend.zig");

pub fn run(api: struct{
    plat_impl: *plat.Impl,
    rend_impl: *rend.Impl,

    init:   *const fn()        anyerror !void,
    update: *const fn(dt: f32) anyerror !void,
    exit:   *const fn()        anyerror !void,

    title:  [:0]const u8,
    width:  u32,
    height: u32,
}) !void {
    const ap = api.plat_impl;
    const ar = api.rend_impl;

    try ap.make(api.rend_impl, api.width,api.height, api.title);
    try ar.make(api.plat_impl);

    try api.init();

    var last_time = ap.get_time();

    while (!api.plat_impl.is_closed()) {
        try ap.poll();

        const time = ap.get_time();
        const delta = time - last_time;
        last_time = time;

        try api.update(delta);

        try ap.swap();
    }

    try api.exit();

    try ar.delete();
    try ap.delete();
}
