const std = @import("std");
const plat = @import("plat.zig");

pub const Impl = struct{
    pub fn make(self: *Impl, p_impl: *plat.Impl) anyerror !void { try self.make_fn(self, p_impl); }
    pub fn delete(self: *Impl) anyerror !void { try self.delete_fn(self); }

    pub fn clear(self: *Impl, col: [4]f32) void { self.clear_fn(self, col); }

    act: *anyopaque,
    name: []const u8,

    make_fn: *const fn(self: *Impl, p_impl: *plat.Impl) anyerror !void,
    delete_fn: *const fn(self: *Impl) anyerror !void,

    clear_fn: *const fn(self: *Impl, col: [4]f32) void,
};
