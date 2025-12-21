const std = @import("std");
const zg = @import("z_goop");
const zrend = zg.rend;

var state: struct{
    arena: std.heap.ArenaAllocator,
    alloc: std.mem.Allocator,

    r: *zrend.Impl,
} = .{};

pub fn init(desc: struct{ 
    rend_impl: *zrend.Impl 
}) !void {
    state.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    state.alloc = state.arena.allocator();

    state.r = desc.rend_impl;
}

pub fn deinit() void {
    state.arena.deinit();
}
