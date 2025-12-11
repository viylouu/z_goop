const std = @import("std");

pub const Impl = struct{
    make:   fn() anyerror !void,
    delete: fn() anyerror !void,

    is_closed: fn() anyerror !bool,
};
