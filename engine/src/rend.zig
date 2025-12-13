const std = @import("std");
const plat = @import("plat.zig");

pub const Impl = struct{
    pub fn make(self: *Impl, p_impl: *plat.Impl) anyerror !void { try self.make_fn(self, p_impl); }
    pub fn delete(self: *Impl) anyerror !void { try self.delete_fn(self); }

    act: *anyopaque,
    name: []const u8,

    make_fn: *const fn(self: *Impl, p_impl: *plat.Impl) anyerror !void,
    delete_fn: *const fn(self: *Impl) anyerror !void,
};
