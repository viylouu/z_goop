const std = @import("std");
const plat = @import("plat.zig");

pub const Impl = struct{
    pub fn make(self: *Impl, p_impl: *plat.Impl) anyerror !void { try self.make_fn(self, p_impl); }
    pub fn delete(self: *Impl) anyerror !void { try self.delete_fn(self); }

    act: *anyopaque,

    make_fn: fn(self: *Impl, p_impl: *plat.Impl) anyerror !void,
    delete_fn: fn(self: *Impl) anyerror !void,
};
