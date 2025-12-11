const std = @import("std");

pub const Impl = struct{
    pub fn make(self: *Impl) anyerror !void { try self.make_fn(self); }
    pub fn delete(self: *Impl) anyerror !void { try self.delete_fn(self); }
    
    pub fn is_closed(self: *Impl) anyerror !bool { return try self.is_closed_fn(self); }

    act: *anyopaque,

    make_fn:   *const fn(self: *Impl) anyerror !void,
    delete_fn: *const fn(self: *Impl) anyerror !void,

    is_closed_fn: *const fn(self: *Impl) anyerror !bool,
};
