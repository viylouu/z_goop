const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;

pub const impl: zplat.Impl = .{
    .make      = Impl.make,
    .delete    = Impl.delete,
    .is_closed = Impl.is_closed,
};

const Impl = struct{
    fn make() !void {

    }

    fn delete() !void {

    }

    fn is_closed() !bool {
        return true;
    }
};
