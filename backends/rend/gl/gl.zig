const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;
const zrend = zg.rend;

const c = @cImport({
    @cInclude("GL/gl.h");
    @cInclude("GL/glext.h");
});

var back = Impl{ .gl = undefined };
pub var impl = zrend.Impl{
    .act          = &back,
    .name         = "gl",

    .make_fn      = Impl.make,
    .delete_fn    = Impl.delete,

    .clear_fn     = Impl.clear,
};

const Impl = struct{
    gl: gl_t,
    const gl_t = struct{
        clear: *const fn (mask: u32) callconv(.c) void,
        clearColor: *const fn (r: f32, g: f32, b: f32, a: f32) callconv(.c) void,

        viewport: *const fn (x: i32, y: i32, w: i32, h: i32) callconv(.c) void,
    };

    fn make(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        try load(self, p_impl);

        ts.gl.viewport(0,0, @intCast(p_impl.width), @intCast(p_impl.height));
    }

    fn delete(self: *zrend.Impl) !void {
        _ = self;
    }

    fn load(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.clear = try loadfn(p_impl, "glClear", *const fn (u32) callconv(.c) void);
        ts.gl.clearColor = try loadfn(p_impl, "glClearColor", *const fn (f32,f32,f32,f32) callconv(.c) void);

        ts.gl.viewport = try loadfn(p_impl, "glViewport", *const fn(i32,i32,i32,i32) callconv(.c) void);
    }

    fn loadfn(p_impl: *zplat.Impl, name: [:0]const u8, comptime T: type) !T {
        return @ptrCast(try p_impl.gl_get_fn_addr(name));
    }

    fn clear(self: *zrend.Impl, col: [4]f32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.clearColor(col[0],col[1],col[2],col[3]);
        ts.gl.clear(c.GL_COLOR_BUFFER_BIT);
    }
};
