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

    // specific

    .gl_get_fn_addr_fn = Impl.gl_get_fn_addr,
};

const Impl = struct{
    window: ?*c.GLFWwindow,

    const err = error{
        GlfwInitFailure,
        OutOfMemory,
        MissingSymbol,
    };

    fn make(self: *zplat.Impl, width: u32, height: u32, title: []const u8) err !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        if (c.glfwInit() == 0)
            return err.GlfwInitFailure;

        var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        defer arena.deinit();
        const alloc = arena.allocator();
        const title_c = try std.mem.concatWithSentinel(alloc, u8, &.{title}, 0);

        ts.window = c.glfwCreateWindow(@intCast(width), @intCast(height), title_c, null,null);
    }

    fn delete(self: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        c.glfwDestroyWindow(ts.window);
        c.glfwTerminate();
    }

    fn is_closed(self: *zplat.Impl) !bool {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        return c.glfwWindowShouldClose(ts.window.?) != 0;
    }

    // specific

    fn gl_get_fn_addr(self: *zplat.Impl, name: [:0]const u8) err !*anyopaque {
        _ = self;

        const ptr = c.glfwGetProcAddress(name);
        if (ptr == null) return err.MissingSymbol;

        return @ptrCast(@constCast(ptr.?));
    }
};
