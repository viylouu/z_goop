const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;

const c = @cImport({
    @cInclude("glfw3.h");
    //@cInclude("glfw3native.h");
});

var back = Impl{ .window = null };
pub var impl: zplat.Impl = .{
    .act          = &back,
    .make_fn      = Impl.make,
    .delete_fn    = Impl.delete,
    .is_closed_fn = Impl.is_closed,
};

const Impl = struct{
    window: ?*c.GLFWwindow,

    const err = error{
        GlfwInitFailure
    };

    fn make(self: *zplat.Impl) err !void {
        _ = self;

        if (c.glfwInit() != 0)
            return err.GlfwInitFailure;
    }

    fn delete(self: *zplat.Impl) !void {
        _ = self;

        c.glfwTerminate();
    }

    fn is_closed(self: *zplat.Impl) !bool {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        return c.glfwWindowShouldClose(ts.window.?) != 0;
    }
};
