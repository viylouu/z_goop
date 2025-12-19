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
    .act                = &back,
    .name               = "gl",

    .make_fn            = Impl.make,
    .delete_fn          = Impl.delete,

    .clear_fn           = Impl.clear,

    .make_buffer_fn     = Impl.make_buffer,
    .delete_buffer_fn   = Impl.delete_buffer,

    .make_pipeline_fn   = Impl.make_pipeline,
    .delete_pipeline_fn = Impl.delete_pipeline,

    .make_shader_fn     = Impl.make_shader,
    .delete_shader_fn   = Impl.delete_shader,
};

pub const err = error{
    InvalidBufferSize,
    BufferCreationFail,
    CantDeleteNullBuffer,
    ShaderCompileFail,
    PipelineLinkFail,
};

const Impl = struct{
    gl: struct{
        clear:      *const fn (
            mask: c.GLbitfield,
            ) callconv(.c) void,
        clearColor: *const fn (
            r: c.GLfloat, 
            g: c.GLfloat, 
            b: c.GLfloat, 
            a: c.GLfloat,
            ) callconv(.c) void,

        viewport: *const fn (
            x: c.GLint, 
            y: c.GLint, 
            w: c.GLint, 
            h: c.GLint,
            ) callconv(.c) void,

        genBuffers:     *const fn (
            n:    c.GLsizei, 
            bufs: *c.GLuint,
            ) callconv(.c) void,
        deleteBuffers:  *const fn (
            n:    c.GLsizei, 
            bufs: *const c.GLuint,
            ) callconv(.c) void,
        bindBuffer:     *const fn (
            target: c.GLenum, 
            buffer: c.GLuint,
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
    
        createShader:  *const fn (
            type: c.GLenum,
            ) callconv(.c) c.GLuint,
        deleteShader:  *const fn (
            shader: c.GLuint,
            ) callconv(.c) void,
        shaderSource:  *const fn (
            shader: c.GLuint,
            count:  c.GLsizei,
            string: [*]const [*:0]const c.GLchar, // what the fuck
            length: ?[*]const c.GLint, //also why
            ) callconv(.c) void,
        compileShader: *const fn (
                shader: c.GLuint,
            ) callconv(.c) void,
        attachShader:  *const fn (
            program: c.GLuint,
            shader:  c.GLuint,
            ) callconv(.c) void,

        createProgram: *const fn (
            ) callconv(.c) c.GLuint,
        deleteProgram: *const fn (
            program: c.GLuint,
            ) callconv(.c) void,
        linkProgram:   *const fn (
            program: c.GLuint,
            ) callconv(.c) void,

        getShaderIv:       *const fn (
            shader: c.GLuint,
            pname:  c.GLenum,
            params: [*]c.GLint,
            ) callconv(.c) void,
        getShaderInfoLog:  *const fn (
            shader:  c.GLuint,
            bufsize: c.GLsizei,
            length:  ?*c.GLsizei,
            infolog: [*]c.GLchar,
            ) callconv(.c) void,
        getProgramIv:      *const fn (
            program: c.GLuint,
            pname:   c.GLenum,
            params:  [*]c.GLint,
            ) callconv(.c) void,
        getProgramInfoLog: *const fn (
            program: c.GLuint,
            bufsize: c.GLsizei,
            length:  ?*c.GLsizei,
            infolog: [*]c.GLchar,
            ) callconv(.c) void,       
    },

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

        ts.gl.createShader  = try loadfn(p_impl, "glCreateShader",  @TypeOf(ts.gl.createShader));
        ts.gl.deleteShader  = try loadfn(p_impl, "glDeleteShader",  @TypeOf(ts.gl.deleteShader));
        ts.gl.shaderSource  = try loadfn(p_impl, "glShaderSource",  @TypeOf(ts.gl.shaderSource));
        ts.gl.compileShader = try loadfn(p_impl, "glCompileShader", @TypeOf(ts.gl.compileShader));
        ts.gl.attachShader  = try loadfn(p_impl, "glAttachShader",  @TypeOf(ts.gl.attachShader));

        ts.gl.createProgram = try loadfn(p_impl, "glCreateProgram", @TypeOf(ts.gl.createProgram));
        ts.gl.deleteProgram = try loadfn(p_impl, "glDeleteProgram", @TypeOf(ts.gl.deleteProgram));
        ts.gl.linkProgram   = try loadfn(p_impl, "glLinkProgram",   @TypeOf(ts.gl.linkProgram));
    
        ts.gl.getShaderIv       = try loadfn(p_impl, "glGetShaderiv",       @TypeOf(ts.gl.getShaderIv));
        ts.gl.getShaderInfoLog  = try loadfn(p_impl, "glGetShaderInfoLog",  @TypeOf(ts.gl.getShaderInfoLog));
        ts.gl.getProgramIv      = try loadfn(p_impl, "glGetProgramiv",      @TypeOf(ts.gl.getProgramIv));
        ts.gl.getProgramInfoLog = try loadfn(p_impl, "glGetProgramInfoLog", @TypeOf(ts.gl.getProgramInfoLog));
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
        var buf = zrend.Buffer{ .id = 0, .desc = desc, };

        if (desc.size == 0) return err.InvalidBufferSize;
        
        ts.gl.genBuffers(1, &buf.id);
        if (buf.id == 0) return err.BufferCreationFail;

        const targ: c.GLenum = switch(desc.type) {
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

    fn make_pipeline(self: *zrend.Impl, desc: zrend.PipelineDesc) !zrend.Pipeline {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        var pln = zrend.Pipeline{ .id = 0, .desc = desc, };

        pln.id = ts.gl.createProgram();

        ts.gl.attachShader(pln.id, desc.vertex_shader.id);
        ts.gl.attachShader(pln.id, desc.fragment_shader.id);
        ts.gl.linkProgram(pln.id);

        var succ: c_int = 0;
        ts.gl.getProgramIv(pln.id, c.GL_LINK_STATUS, @ptrCast(&succ));
        if (succ == 0) {
            var len: c_int = 0;
            ts.gl.getProgramIv(pln.id, c.GL_INFO_LOG_LENGTH, @ptrCast(&len));

            const log = try std.heap.c_allocator.alloc(u8, @intCast(len));
            defer std.heap.c_allocator.free(log);

            ts.gl.getShaderInfoLog(
                pln.id,
                len,
                null,
                log.ptr
                );

            std.log.warn("pipeline linking error!\n{s}\n", .{log});

            ts.gl.deleteProgram(pln.id);

            return err.ShaderCompileFail;
        }

        return pln;
    }
    fn delete_pipeline(self: *zrend.Impl, pipeline: *zrend.Pipeline) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        std.debug.assert(pipeline.id != 0);

        ts.gl.deleteProgram(pipeline.id);
        pipeline.id = 0;
    }

    fn make_shader(self: *zrend.Impl, desc: zrend.ShaderDesc) !zrend.Shader {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        var sha = zrend.Shader{ .id = 0, .desc = desc, };

        const usage: c.GLenum = switch(desc.type) {
            .vertex => c.GL_VERTEX_SHADER,
            .fragment => c.GL_FRAGMENT_SHADER,
        };

        sha.id = ts.gl.createShader(usage);
        ts.gl.shaderSource(sha.id, 1, &.{ desc.source }, null);
        ts.gl.compileShader(sha.id);

        var succ: c_int = 0;
        ts.gl.getShaderIv(sha.id, c.GL_COMPILE_STATUS, @ptrCast(&succ));
        if (succ == 0) {
            var len: c_int = 0;
            ts.gl.getShaderIv(sha.id, c.GL_INFO_LOG_LENGTH, @ptrCast(&len));

            const log = try std.heap.c_allocator.alloc(u8, @intCast(len));
            defer std.heap.c_allocator.free(log);

            ts.gl.getShaderInfoLog(
                sha.id,
                len,
                null,
                log.ptr
                );

            std.log.warn("shader compile error!\n{s}\n", .{log});

            ts.gl.deleteShader(sha.id);

            return err.ShaderCompileFail;
        }

        return sha;
    }
    fn delete_shader(self: *zrend.Impl, shader: *zrend.Shader) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        std.debug.assert(shader.id != 0);

        ts.gl.deleteShader(shader.id);
        shader.id = 0;
    }
};
