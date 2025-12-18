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
    .act              = &back,
    .name             = "gl",

    .make_fn          = Impl.make,
    .delete_fn        = Impl.delete,

    .clear_fn         = Impl.clear,

    .make_buffer_fn   = Impl.make_buffer,
    .delete_buffer_fn = Impl.delete_buffer,
};

pub const err = error{
    InvalidBufferSize,
    BufferCreationFail,
    CantDeleteNullBuffer,
};

const Impl = struct{
    gl: gl_t,
    const gl_t = struct{
        clear:      *const fn (
            mask: c.GLbitfield
            ) callconv(.c) void,
        clearColor: *const fn (
            r: c.GLfloat, 
            g: c.GLfloat, 
            b: c.GLfloat, 
            a: c.GLfloat
            ) callconv(.c) void,

        viewport: *const fn (
            x: c.GLint, 
            y: c.GLint, 
            w: c.GLint, 
            h: c.GLint
            ) callconv(.c) void,

        genBuffers:     *const fn (
            n:    c.GLsizei, 
            bufs: *c.GLuint
            ) callconv(.c) void,
        deleteBuffers:  *const fn (
            n:    c.GLsizei, 
            bufs: *const c.GLuint
            ) callconv(.c) void,
        bindBuffer:     *const fn (
            target: c.GLenum, 
            buffer: c.GLuint
            ) callconv(.c) void,
        bufferData:     *const fn (
            target: c.GLenum,
            size:   c.GLsizeiptr,
            data:   ?*const anyopaque,
            usage:  c.GLenum,
            ) callconv(.c) void,
        bindBufferBase: *const fn (
            target: c.GLenum,
            index:  c.GLuint,
            buffer: c.GLuint,
            ) callconv(.c) void,
    };

    fn make(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        try load(self, p_impl);

        ts.gl.viewport(0,0, @intCast(p_impl.width), @intCast(p_impl.height));
    }
    fn delete(self: *zrend.Impl) void {
        _ = self;
    }

    fn load(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.clear      = try loadfn(p_impl, "glClear",      @TypeOf(ts.gl.clear));
        ts.gl.clearColor = try loadfn(p_impl, "glClearColor", @TypeOf(ts.gl.clearColor));

        ts.gl.viewport = try loadfn(p_impl, "glViewport", @TypeOf(ts.gl.viewport));

        ts.gl.genBuffers     = try loadfn(p_impl, "glGenBuffers",     @TypeOf(ts.gl.genBuffers));
        ts.gl.deleteBuffers  = try loadfn(p_impl, "glDeleteBuffers",  @TypeOf(ts.gl.deleteBuffers));
        ts.gl.bindBuffer     = try loadfn(p_impl, "glBindBuffer",     @TypeOf(ts.gl.bindBuffer));
        ts.gl.bufferData     = try loadfn(p_impl, "glBufferData",     @TypeOf(ts.gl.bufferData));
        ts.gl.bindBufferBase = try loadfn(p_impl, "glBindBufferBase", @TypeOf(ts.gl.bindBufferBase));
    }
    fn loadfn(p_impl: *zplat.Impl, name: [:0]const u8, comptime T: type) !T {
        return @ptrCast(try p_impl.gl_get_fn_addr(name));
    }

    fn clear(self: *zrend.Impl, col: [4]f32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.clearColor(col[0],col[1],col[2],col[3]);
        ts.gl.clear(c.GL_COLOR_BUFFER_BIT);
    }

    fn make_buffer(self: *zrend.Impl, desc: zrend.BufferDesc, data: ?[]const u8) !zrend.Buffer {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        var buf = zrend.Buffer{ .id = 0, .desc = desc };

        if (desc.size == 0) return err.InvalidBufferSize;
        
        ts.gl.genBuffers(1, &buf.id);
        if (buf.id == 0) return err.BufferCreationFail;

        const targ = switch(desc.type) {
                .vertex, .instance => c.GL_ARRAY_BUFFER,
                .index             => c.GL_ELEMENT_ARRAY_BUFFER,
                .uniform           => c.GL_UNIFORM_BUFFER,
                .storage           => c.GL_SHADER_STORAGE_BUFFER,
            };

        ts.gl.bindBuffer(targ, buf.id);
        ts.gl.bufferData(
            targ,
            desc.size,
            if (data) |d| d.ptr else null,
            c.GL_DYNAMIC_DRAW,
            );
        ts.gl.bindBuffer(targ, 0);

        return buf;
    }
    fn delete_buffer(self: *zrend.Impl, buffer: *zrend.Buffer) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        std.debug.assert(buffer.id != 0);

        ts.gl.deleteBuffers(1, &buffer.id);
        buffer.id = 0;
    }
};
