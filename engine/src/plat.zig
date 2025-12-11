const std = @import("std");

pub const Impl = struct{
    pub fn make(self: *Impl, width: u32, height: u32, title: []const u8) anyerror !void { try self.make_fn(self, width,height, title); }
    pub fn delete(self: *Impl) anyerror !void { try self.delete_fn(self); }
    
    pub fn is_closed(self: *Impl) anyerror !bool { return try self.is_closed_fn(self); }

    act: *anyopaque,

    make_fn:   *const fn(self: *Impl, width: u32, height: u32, title: []const u8) anyerror !void,
    delete_fn: *const fn(self: *Impl) anyerror !void,

    is_closed_fn: *const fn(self: *Impl) anyerror !bool,
};
