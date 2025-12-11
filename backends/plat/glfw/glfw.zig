const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;

const c = @cImport({
    @cInclude("glfw3.h");
    //@cInclude("glfw3native.h");
});

pub const impl: zplat.Impl = .{
    .make      = Impl.make,
    .delete    = Impl.delete,
    .is_closed = Impl.is_closed,
};

const Impl = struct{
    window: *c.GLFWwindow,

    fn make(self: *Impl) error{
        GlfwInitFailure
    } !void {
        _ = self;

        if (c.glfwInit() != 0)
            return .GlfwInitFailure;
    }

    fn delete(self: *Impl) !void {
        _ = self;

        c.glfwTerminate();
    }

    fn is_closed(self: *Impl) !bool {
        return c.glfwWindowShouldClose(self.window);
    }
};
