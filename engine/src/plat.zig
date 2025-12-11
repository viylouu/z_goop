const std = @import("std");

pub const Impl = struct{
    make:   fn(self: *anyopaque) anyerror !void,
    delete: fn(self: *anyopaque) anyerror !void,

    is_closed: fn(self: *anyopaque) anyerror !bool,
};
