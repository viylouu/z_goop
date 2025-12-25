const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;
const zrend = zg.rend;

const c = @cImport({
    @cInclude("glfw3.h");
    //@cInclude("glfw3native.h");
});

var back = Impl{ .window = undefined, };
pub var impl = zplat.Impl{
    .act          = &back,
    .name         = "glfw",

    .width        = undefined,
    .height       = undefined,

    .keys         = [_]zplat.KeyState{.Inactive} ** std.meta.fields(zplat.Key).len,
    .mousebuts    = [_]zplat.KeyState{.Inactive} ** std.meta.fields(zplat.Mouse).len,
    .mouse        = .{.x = 0, .y = 0},

    .make_fn      = Impl.make,
    .delete_fn    = Impl.delete,

    .get_time_fn  = Impl.get_time,

    .is_closed_fn = Impl.is_closed,
    .poll_fn      = Impl.poll,
    .swap_fn      = Impl.swap,

    // specific

    .gl_get_fn_addr_fn = Impl.gl_get_fn_addr,
};

const Impl = struct{
    window: *c.GLFWwindow,

    const err = error{
        GlfwInitFailure,
        GlfwCreateWindowFailure,
        OutOfMemory,
        MissingSymbol,
    };

    fn _fbscb(window: ?*c.GLFWwindow, width: c_int, height: c_int) callconv(.c) void {
        std.debug.assert(window != null);
        const self: *zplat.Impl = @ptrCast(@alignCast(c.glfwGetWindowUserPointer(window).?));
        self.*.width = @intCast(width);
        self.*.height = @intCast(height);
    }

    fn make(self: *zplat.Impl, r_impl: *zrend.Impl, width: u32, height: u32, title: [:0]const u8) err !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        //c.glfwInitHint(c.GLFW_PLATFORM, c.GLFW_PLATFORM_X11); // for testing because qrenderdoc

        if (c.glfwInit() == 0)
            return err.GlfwInitFailure;

        if (std.mem.eql(u8, r_impl.name, "gl")) {
            c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_OPENGL_API);
            c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MAJOR, 3);
            c.glfwWindowHint(c.GLFW_CONTEXT_VERSION_MINOR, 3);
            c.glfwWindowHint(c.GLFW_OPENGL_PROFILE, c.GLFW_OPENGL_CORE_PROFILE);
            c.glfwWindowHint(c.GLFW_OPENGL_FORWARD_COMPAT, c.GLFW_TRUE);
        } else
            c.glfwWindowHint(c.GLFW_CLIENT_API, c.GLFW_NO_API);

        c.glfwWindowHint(c.GLFW_RESIZABLE, c.GLFW_TRUE);

        self.width = width;
        self.height = height;
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

        c.glfwSetWindowUserPointer(ts.window, self);
        _ = c.glfwSetFramebufferSizeCallback(ts.window, _fbscb);

        c.glfwSwapInterval(1);
    }
    fn delete(self: *zplat.Impl) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        // fix for segfault on exit
        c.glfwPollEvents();

        c.glfwDestroyWindow(ts.window);
        c.glfwTerminate();
    }

    fn get_time(self: *zplat.Impl) f32 {
        _ = self;
        return @floatCast(c.glfwGetTime());
    }

    fn is_closed(self: *zplat.Impl) bool {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        return c.glfwWindowShouldClose(ts.window) != 0;
    }

    fn upk(self: *zplat.Impl, z: zplat.Key, g: c_int) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        const i = @intFromEnum(z);

        const p = self.keys[i];
        self.keys[i] = if(c.glfwGetKey(ts.window, g) == 1) .Pressed else .Released;
        if (self.keys[i] == .Pressed and (p == .Pressed or p == .Held)) self.keys[i] = .Held;
        if (self.keys[i] == .Released and (p == .Released or p == .Inactive)) self.keys[i] = .Inactive;
    }

    fn upm(self: *zplat.Impl, z: zplat.Mouse, g: c_int) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        const i = @intFromEnum(z);

        const p = self.mousebuts[i];
        self.mousebuts[i] = if(c.glfwGetMouseButton(ts.window, g) == 1) .Pressed else .Released;
        if (self.mousebuts[i] == .Pressed and (p == .Pressed or p == .Held)) self.mousebuts[i] = .Held;
        if (self.mousebuts[i] == .Released and (p == .Released or p == .Inactive)) self.mousebuts[i] = .Inactive;
    }

    fn poll(self: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        c.glfwPollEvents();

        upk(self, .Escape, c.GLFW_KEY_ESCAPE);
        upk(self, .Caps, c.GLFW_KEY_CAPS_LOCK);
        upk(self, .Space, c.GLFW_KEY_SPACE);
        upk(self, .Tab, c.GLFW_KEY_TAB);
        upk(self, .Backspace, c.GLFW_KEY_BACKSPACE);
        upk(self, .Delete, c.GLFW_KEY_DELETE);
        upk(self, .Home, c.GLFW_KEY_HOME);
        upk(self, .End, c.GLFW_KEY_END);
        upk(self, .PageUp, c.GLFW_KEY_PAGE_UP);
        upk(self, .PageDown, c.GLFW_KEY_PAGE_DOWN);
        upk(self, .Insert, c.GLFW_KEY_INSERT);

        upk(self, .LShift, c.GLFW_KEY_LEFT_SHIFT);
        upk(self, .RShift, c.GLFW_KEY_RIGHT_SHIFT);
        upk(self, .LCtrl, c.GLFW_KEY_LEFT_CONTROL);
        upk(self, .RCtrl, c.GLFW_KEY_RIGHT_CONTROL);
        upk(self, .LAlt, c.GLFW_KEY_LEFT_ALT);
        upk(self, .RAlt, c.GLFW_KEY_RIGHT_ALT);
        upk(self, .LSuper, c.GLFW_KEY_LEFT_SUPER);
        upk(self, .RSuper, c.GLFW_KEY_RIGHT_SUPER);

        upk(self, .Up, c.GLFW_KEY_UP);
        upk(self, .Left, c.GLFW_KEY_LEFT);
        upk(self, .Right, c.GLFW_KEY_RIGHT);
        upk(self, .Down, c.GLFW_KEY_DOWN);

        for (@intFromEnum(zplat.Key.A)..@intFromEnum(zplat.Key.Z)+1) |k| upk(self, @enumFromInt(k), @as(c_int, @intCast(k-@intFromEnum(zplat.Key.A)))+c.GLFW_KEY_A);
        for (@intFromEnum(zplat.Key.K1)..@intFromEnum(zplat.Key.K9)+1) |k| upk(self, @enumFromInt(k), @as(c_int, @intCast(k-@intFromEnum(zplat.Key.K1)))+c.GLFW_KEY_1);
            upk(self, .K0, c.GLFW_KEY_0);
        for (@intFromEnum(zplat.Key.F1)..@intFromEnum(zplat.Key.F12)+1) |k| upk(self, @enumFromInt(k), @as(c_int, @intCast(k-@intFromEnum(zplat.Key.F1)))+c.GLFW_KEY_F1);

        upm(self, .Left, c.GLFW_MOUSE_BUTTON_LEFT);
        upm(self, .Right, c.GLFW_MOUSE_BUTTON_RIGHT);
        upm(self, .Middle, c.GLFW_MOUSE_BUTTON_MIDDLE);

        var mx: f64 = @floatCast(self.mouse.x);
        var my: f64 = @floatCast(self.mouse.y);
        c.glfwGetCursorPos(ts.window, &mx, &my);
        self.mouse.x = @floatCast(mx);
        self.mouse.y = @floatCast(my);
    }
    fn swap(self: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        c.glfwSwapBuffers(ts.window);
    }

    // specific

    fn gl_get_fn_addr(self: *zplat.Impl, name: [:0]const u8) err !*anyopaque {
        _ = self;

        const ptr = c.glfwGetProcAddress(name);
        if (ptr == null) return err.MissingSymbol;

        return @ptrCast(@constCast(ptr.?));
    }
};
