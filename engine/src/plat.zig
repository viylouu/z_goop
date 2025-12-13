const std = @import("std");
const rend = @import("rend.zig");

pub const Impl = struct{
    pub fn make(self: *Impl, r_impl: *rend.Impl, width: u32, height: u32, title: [:0]const u8) anyerror !void { try self.make_fn(self, r_impl, width,height, title); }
    pub fn delete(self: *Impl) anyerror !void { try self.delete_fn(self); }
    
    pub fn is_closed(self: *Impl) anyerror !bool { return try self.is_closed_fn(self); }

    pub fn gl_get_fn_addr(self: *Impl, name: [:0]const u8) anyerror !*anyopaque { return try self.gl_get_fn_addr_fn(self, name); }

    act: *anyopaque,
    name: []const u8,

    make_fn:   *const fn(self: *Impl, r_impl: *rend.Impl, width: u32, height: u32, title: [:0]const u8) anyerror !void,
    delete_fn: *const fn(self: *Impl) anyerror !void,

    is_closed_fn: *const fn(self: *Impl) anyerror !bool,

    // specific stuff

    gl_get_fn_addr_fn: *const fn(self: *Impl, name: [:0]const u8) anyerror !*anyopaque,
};
