const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;
const zrend = zg.rend;

const c = @cImport({
    @cInclude("GL/gl.h");
    @cInclude("GL/glext.h");
});

var back = Impl{ .trash = 0 };
pub var impl: zrend.Impl = .{
    .act          = &back,
    .make_fn      = Impl.make,
    .delete_fn    = Impl.delete,
};

const Impl = struct{
    trash: u32,

    fn make(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        _ = self;
        _ = p_impl;
    }

    fn delete(self: *zrend.Impl) !void {
        _ = self;
    }
};
