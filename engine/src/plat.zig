const std = @import("std");
const rend = @import("rend.zig");

pub const Impl = struct{
    pub fn make(self: *Impl, r_impl: *rend.Impl, width: u32, height: u32, title: [:0]const u8) anyerror !void { 
        try self.make_fn(self, r_impl, width,height, title); 
    }
    pub fn delete(self: *Impl) void { 
        self.delete_fn(self); 
    }

    pub fn get_time(self: *Impl) f32 { 
        return self.get_time_fn(self); 
    }

    pub fn is_closed(self: *Impl) bool { 
        return self.is_closed_fn(self); 
    }
    pub fn poll(self: *Impl) anyerror !void { 
        try self.poll_fn(self); 
    }
    pub fn swap(self: *Impl) anyerror !void { 
        try self.swap_fn(self); 
    }

    pub fn gl_get_fn_addr(self: *Impl, name: [:0]const u8) anyerror !*anyopaque { return try self.gl_get_fn_addr_fn(self, name); }

    act: *anyopaque,
    name: []const u8,

    width: u32,
    height: u32,

    make_fn:   *const fn(self: *Impl, r_impl: *rend.Impl, width: u32, height: u32, title: [:0]const u8) anyerror !void,
    delete_fn: *const fn(self: *Impl) void,

    get_time_fn: *const fn(self: *Impl) f32,

    is_closed_fn: *const fn(self: *Impl) bool,
    poll_fn: *const fn(self: *Impl) anyerror !void,
    swap_fn: *const fn(self: *Impl) anyerror !void,

    // specific stuff

    gl_get_fn_addr_fn: *const fn(self: *Impl, name: [:0]const u8) anyerror !*anyopaque,
};
