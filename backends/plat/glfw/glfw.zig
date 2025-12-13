const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;
const zrend = zg.rend;

const c = @cImport({
    @cInclude("glfw3.h");
    //@cInclude("glfw3native.h");
});

var back = Impl{ .window = undefined, .width = undefined, .height = undefined };
pub var impl: zplat.Impl = .{
    .act          = &back,
    .name         = "glfw",

    .make_fn      = Impl.make,
    .delete_fn    = Impl.delete,

    .is_closed_fn = Impl.is_closed,

    // specific

    .gl_get_fn_addr_fn = Impl.gl_get_fn_addr,
};

const Impl = struct{
    window: *c.GLFWwindow,

    width: u32,
    height: u32,

    const err = error{
        GlfwInitFailure,
        GlfwCreateWindowFailure,
        OutOfMemory,
        MissingSymbol,
    };

    fn make(self: *zplat.Impl, r_impl: *zrend.Impl, width: u32, height: u32, title: [:0]const u8) err !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        if (c.glfwInit() == 0)
            return err.GlfwInitFailure;

        if (std.mem.eql(u8, r_impl.name, "gl")) {
            c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
            c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
            c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
            c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GLFW_TRUE);
        } else
            c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);

        c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_TRUE);

        ts.width = width;
        ts.height = height;
        const window = c.glfwCreateWindow(@intCast(width), @intCast(height), title, null,null);
        if (window == null)
            return err.GlfwCreateWindowFailure;
        ts.window = window.?;

        if (std.mem.eql(u8, r_impl.name, "gl"))
            c.glfwMakeContextCurrent(ts.window);

        // undiable fish mode
        c.glfwShowWindow(ts.window);
        c.glfwPollEvents();
        c.glfwSetWindowSize(ts.window, @intCast(width), @intCast(height));
    }

    fn delete(self: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        c.glfwDestroyWindow(ts.window);
        c.glfwTerminate();
    }

    fn is_closed(self: *zplat.Impl) !bool {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        return c.glfwWindowShouldClose(ts.window) != 0;
    }

    // specific

    fn gl_get_fn_addr(self: *zplat.Impl, name: [:0]const u8) err !*anyopaque {
        _ = self;

        const ptr = c.glfwGetProcAddress(name);
        if (ptr == null) return err.MissingSymbol;

        return @ptrCast(@constCast(ptr.?));
    }
};
