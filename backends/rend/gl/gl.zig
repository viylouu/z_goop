const std = @import("std");
const zg = @import("z_goop");
const zplat = zg.plat;
const zrend = zg.rend;

const c = @cImport({
    @cInclude("GL/gl.h");
    @cInclude("GL/glext.h");
});

var back = Impl{ .gl = undefined, .cur_pipe = undefined, .cur_index_buf = null, .dummy_vao = 0, };
pub var impl = zrend.Impl{
    .act                = &back,
    .name               = "gl",

    .width              = undefined,
    .height             = undefined,

    .make_fn            = Impl.make,
    .delete_fn          = Impl.delete,

    .resize_fn          = Impl.resize,

    .clear_fn           = Impl.clear,

    .make_buffer_fn     = Impl.make_buffer,
    .delete_buffer_fn   = Impl.delete_buffer,

    .make_pipeline_fn   = Impl.make_pipeline,
    .delete_pipeline_fn = Impl.delete_pipeline,

    .make_shader_fn     = Impl.make_shader,
    .delete_shader_fn   = Impl.delete_shader,

    .make_texture_fn    = Impl.make_texture,
    .delete_texture_fn  = Impl.delete_texture,

    .update_buffer_fn   = Impl.update_buffer,

    .bind_pipeline_fn   = Impl.bind_pipeline,
    .bind_buffer_fn     = Impl.bind_buffer,
    .bind_texture_fn    = Impl.bind_texture,

    .draw_fn            = Impl.draw,
};

pub const err = error{
    InvalidBufferSize,
    BufferCreationFail,
    CantDeleteNullBuffer,
    ShaderCompileFail,
    PipelineLinkFail,
    TextureCreationFail,
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
        
        enable:  *const fn (
            index: c.GLuint,
            ) callconv(.c) void,
        disable: *const fn (
            index: c.GLuint,
            ) callconv(.c) void,

        cullFace:  *const fn (
            mode: c.GLenum,
            ) callconv(.c) void,

        depthFunc: *const fn (
            mode: c.GLenum,
            ) callconv(.c) void,
        depthMask: *const fn (
            flag: c.GLboolean,
            ) callconv(.c) void,

        blendFuncSeparate:     *const fn (
            srcrgb:   c.GLenum,
            dstrgb:   c.GLenum,
            srcalpha: c.GLenum,
            dstalpha: c.GLenum,
            ) callconv(.c) void,
        blendEquationSeparate: *const fn (
            modergb:   c.GLenum,
            modealpha: c.GLenum,
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
        bufferSubData:  *const fn (
            target: c.GLenum,
            offset: c.GLintptr,
            size:   c.GLsizeiptr,
            data:   ?*const anyopaque
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
        useProgram:    *const fn (
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
    
        enableVertexAttribArray: *const fn (
            index: c.GLuint,
            ) callconv(.c) void,
        vertexAttribPointer:     *const fn (
            index:      c.GLuint,
            size:       c.GLint,
            type:       c.GLenum,
            normalized: c.GLboolean,
            stride:     c.GLsizei,
            pointer:    *const anyopaque,
            ) callconv(.c) void,
        vertexAttribDivisor:     *const fn (
            index:   c.GLuint,
            divisor: c.GLuint,
            ) callconv(.c) void,

        drawArraysInstanced:   *const fn (
            mode:  c.GLenum,
            first: c.GLint,
            count: c.GLsizei,
            instancecount: c.GLsizei,
            ) callconv(.c) void,
        drawElementsInstanced: *const fn (
            mode:    c.GLenum,
            count:   c.GLsizei,
            type:    c.GLenum,
            indices: ?*const anyopaque,
            instancecount: c.GLsizei,
            ) callconv(.c) void,
    
        genVertexArrays:    *const fn (
            n:      c.GLsizei,
            arrays: [*]c.GLuint,
            ) callconv(.c) void,
        deleteVertexArrays: *const fn (
            n:      c.GLsizei,
            arrays: [*]const c.GLuint,
            ) callconv(.c) void,
        bindVertexArray:    *const fn (
            array: c.GLuint,
            ) callconv(.c) void,
    
        genTextures:    *const fn(
            n:        c.GLsizei,
            textures: *c.GLuint,
            ) callconv(.c) void,
        deleteTextures: *const fn(
            n:        c.GLsizei,
            textures: *c.GLuint,
            ) callconv(.c) void,
        bindTexture:    *const fn(
            target:  c.GLenum,
            texture: c.GLuint,
            ) callconv(.c) void,
        texImage2D:     *const fn(
            target: c.GLenum,
            level:  c.GLint,
            internalformat: c.GLint,
            width:  c.GLsizei,
            height: c.GLsizei,
            border: c.GLint,
            format: c.GLenum,
            type:   c.GLenum,
            pixels: ?*const anyopaque,
            ) callconv(.c) void,
        texParameterI:  *const fn(
            target: c.GLenum,
            pname:  c.GLenum,
            param:  c.GLint,
            ) callconv(.c) void,
        activeTexture:  *const fn(
            texture: c.GLenum,
            ) callconv(.c) void,
    
        uniform1i: *const fn(
            location: c.GLint,
            v0:       c.GLint,
            ) callconv(.c) void,
    },

    cur_pipe: *zrend.Pipeline,
    cur_index_buf: ?*zrend.Buffer,
    dummy_vao: c.GLuint,

    fn make(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        try load(self, p_impl);

        ts.gl.viewport(0,0, @intCast(p_impl.width), @intCast(p_impl.height));

        ts.gl.genVertexArrays(1, @ptrCast(&ts.dummy_vao));
    }
    fn delete(self: *zrend.Impl) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        ts.gl.deleteVertexArrays(1, @ptrCast(&ts.dummy_vao));
    }

    fn resize(self: *zrend.Impl, width: u32, height: u32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        ts.gl.viewport(0,0, @intCast(width), @intCast(height));
        self.width = width;
        self.height = height;
    }

    fn load(self: *zrend.Impl, p_impl: *zplat.Impl) !void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.clear      = try loadfn(p_impl, "glClear",      @TypeOf(ts.gl.clear));
        ts.gl.clearColor = try loadfn(p_impl, "glClearColor", @TypeOf(ts.gl.clearColor));

        ts.gl.viewport = try loadfn(p_impl, "glViewport", @TypeOf(ts.gl.viewport));

        ts.gl.enable  = try loadfn(p_impl, "glEnable",  @TypeOf(ts.gl.enable));
        ts.gl.disable = try loadfn(p_impl, "glDisable", @TypeOf(ts.gl.disable));

        ts.gl.cullFace = try loadfn(p_impl, "glCullFace", @TypeOf(ts.gl.cullFace));

        ts.gl.depthFunc = try loadfn(p_impl, "glDepthFunc", @TypeOf(ts.gl.depthFunc));
        ts.gl.depthMask = try loadfn(p_impl, "glDepthMask", @TypeOf(ts.gl.depthMask));

        ts.gl.blendFuncSeparate     = try loadfn(p_impl, "glBlendFuncSeparate",     @TypeOf(ts.gl.blendFuncSeparate));
        ts.gl.blendEquationSeparate = try loadfn(p_impl, "glBlendEquationSeparate", @TypeOf(ts.gl.blendEquationSeparate));

        ts.gl.genBuffers     = try loadfn(p_impl, "glGenBuffers",     @TypeOf(ts.gl.genBuffers));
        ts.gl.deleteBuffers  = try loadfn(p_impl, "glDeleteBuffers",  @TypeOf(ts.gl.deleteBuffers));
        ts.gl.bindBuffer     = try loadfn(p_impl, "glBindBuffer",     @TypeOf(ts.gl.bindBuffer));
        ts.gl.bufferData     = try loadfn(p_impl, "glBufferData",     @TypeOf(ts.gl.bufferData));
        ts.gl.bindBufferBase = try loadfn(p_impl, "glBindBufferBase", @TypeOf(ts.gl.bindBufferBase));
        ts.gl.bufferSubData  = try loadfn(p_impl, "glBufferSubData",  @TypeOf(ts.gl.bufferSubData));

        ts.gl.createShader  = try loadfn(p_impl, "glCreateShader",  @TypeOf(ts.gl.createShader));
        ts.gl.deleteShader  = try loadfn(p_impl, "glDeleteShader",  @TypeOf(ts.gl.deleteShader));
        ts.gl.shaderSource  = try loadfn(p_impl, "glShaderSource",  @TypeOf(ts.gl.shaderSource));
        ts.gl.compileShader = try loadfn(p_impl, "glCompileShader", @TypeOf(ts.gl.compileShader));
        ts.gl.attachShader  = try loadfn(p_impl, "glAttachShader",  @TypeOf(ts.gl.attachShader));

        ts.gl.createProgram = try loadfn(p_impl, "glCreateProgram", @TypeOf(ts.gl.createProgram));
        ts.gl.deleteProgram = try loadfn(p_impl, "glDeleteProgram", @TypeOf(ts.gl.deleteProgram));
        ts.gl.linkProgram   = try loadfn(p_impl, "glLinkProgram",   @TypeOf(ts.gl.linkProgram));
        ts.gl.useProgram    = try loadfn(p_impl, "glUseProgram",    @TypeOf(ts.gl.useProgram));
    
        ts.gl.getShaderIv       = try loadfn(p_impl, "glGetShaderiv",       @TypeOf(ts.gl.getShaderIv));
        ts.gl.getShaderInfoLog  = try loadfn(p_impl, "glGetShaderInfoLog",  @TypeOf(ts.gl.getShaderInfoLog));
        ts.gl.getProgramIv      = try loadfn(p_impl, "glGetProgramiv",      @TypeOf(ts.gl.getProgramIv));
        ts.gl.getProgramInfoLog = try loadfn(p_impl, "glGetProgramInfoLog", @TypeOf(ts.gl.getProgramInfoLog));

        ts.gl.enableVertexAttribArray = try loadfn(p_impl, "glEnableVertexAttribArray", @TypeOf(ts.gl.enableVertexAttribArray));
        ts.gl.vertexAttribPointer     = try loadfn(p_impl, "glVertexAttribPointer",     @TypeOf(ts.gl.vertexAttribPointer));
        ts.gl.vertexAttribDivisor     = try loadfn(p_impl, "glVertexAttribDivisor",     @TypeOf(ts.gl.vertexAttribDivisor));

        ts.gl.drawArraysInstanced   = try loadfn(p_impl, "glDrawArraysInstanced",    @TypeOf(ts.gl.drawArraysInstanced));
        ts.gl.drawElementsInstanced = try loadfn(p_impl, "glDrawElementsInstanced", @TypeOf(ts.gl.drawElementsInstanced));
    
        ts.gl.genVertexArrays    = try loadfn(p_impl, "glGenVertexArrays",    @TypeOf(ts.gl.genVertexArrays));
        ts.gl.deleteVertexArrays = try loadfn(p_impl, "glDeleteVertexArrays", @TypeOf(ts.gl.deleteVertexArrays));
        ts.gl.bindVertexArray    = try loadfn(p_impl, "glBindVertexArray",    @TypeOf(ts.gl.bindVertexArray));
    
        ts.gl.genTextures    = try loadfn(p_impl, "glGenTextures",    @TypeOf(ts.gl.genTextures));
        ts.gl.deleteTextures = try loadfn(p_impl, "glDeleteTextures", @TypeOf(ts.gl.deleteTextures));
        ts.gl.bindTexture    = try loadfn(p_impl, "glBindTexture",    @TypeOf(ts.gl.bindTexture));
        ts.gl.texImage2D     = try loadfn(p_impl, "glTexImage2D",     @TypeOf(ts.gl.texImage2D));
        ts.gl.texParameterI  = try loadfn(p_impl, "glTexParameteri",  @TypeOf(ts.gl.texParameterI));
        ts.gl.activeTexture  = try loadfn(p_impl, "glActiveTexture",  @TypeOf(ts.gl.activeTexture));
    
        ts.gl.uniform1i = try loadfn(p_impl, "glUniform1i", @TypeOf(ts.gl.uniform1i));
    }
    fn loadfn(p_impl: *zplat.Impl, name: [:0]const u8, comptime T: type) !T {
        return @ptrCast(try p_impl.gl_get_fn_addr(name));
    }

    fn clear(self: *zrend.Impl, col: [4]f32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.clearColor(col[0],col[1],col[2],col[3]);
        ts.gl.clear(c.GL_COLOR_BUFFER_BIT | c.GL_DEPTH_BUFFER_BIT);
    }

    fn make_buffer(self: *zrend.Impl, desc: zrend.BufferDesc, data: ?[]const u8) !zrend.Buffer {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        var buf = zrend.Buffer{ .id = 0, .desc = desc, };

        if (desc.size == 0) return err.InvalidBufferSize;
        
        ts.gl.genBuffers(1, &buf.id);
        if (buf.id == 0) return err.BufferCreationFail;

        const targ: c.GLenum = me_to_gl_buffer_type(desc.type);

        ts.gl.bindBuffer(targ, buf.id);
        ts.gl.bufferData(
            targ,
            @intCast(desc.size),
            if (data) |d| d.ptr else null,
            me_to_gl_buffer_usage(desc.usage),
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
            .Vertex => c.GL_VERTEX_SHADER,
            .Fragment => c.GL_FRAGMENT_SHADER,
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

    fn make_texture(self: *zrend.Impl, desc: zrend.TextureDesc, data: ?[]const u8) !zrend.Texture {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        var tex = zrend.Texture{ .id = 0, .desc = desc, };

        ts.gl.genTextures(1, &tex.id);
        if (tex.id == 0) return err.TextureCreationFail;

        const target = me_to_gl_texture_type(desc.type);

        ts.gl.bindTexture(target, tex.id);

        const sampling = me_to_gl_texturesampling(desc.sampling);
        const wrap = me_to_gl_texture_wrap(desc.wrap);

        ts.gl.texParameterI(target, c.GL_TEXTURE_MIN_FILTER, @intCast(sampling));
        ts.gl.texParameterI(target, c.GL_TEXTURE_MAG_FILTER, @intCast(sampling));
        ts.gl.texParameterI(target, c.GL_TEXTURE_WRAP_S, @intCast(wrap));
        ts.gl.texParameterI(target, c.GL_TEXTURE_WRAP_T, @intCast(wrap));

        const fmt = me_to_gl_texture_fmt(desc.fmt);

        ts.gl.texImage2D(
            target,
            0,
            fmt.internal,
            @intCast(desc.width),
            @intCast(desc.height),
            0,
            fmt.format,
            fmt.type,
            if (data) |d| d.ptr else null,
            );

        ts.gl.bindTexture(target, 0);

        return tex;
    }
    fn delete_texture(self: *zrend.Impl, texture: *zrend.Texture) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        std.debug.assert(texture.id != 0);

        ts.gl.deleteTextures(1, &texture.id);
        texture.id = 0;
    }

    fn me_to_gl_cullmode(cull: zrend.CullMode) c.GLenum {
        return switch(cull) {
            .Back  => c.GL_BACK,
            .Front => c.GL_FRONT,
            .None  => unreachable,
        };
    }
    fn me_to_gl_cmpop(cmpop: zrend.CompareOp) c.GLenum {
        return switch(cmpop) {
            .Never        => c.GL_NEVER,
            .Less         => c.GL_LESS,
            .Greater      => c.GL_GREATER,
            .Equal        => c.GL_EQUAL,
            .NotEqual     => c.GL_NOTEQUAL,
            .LessEqual    => c.GL_LEQUAL,
            .GreaterEqual => c.GL_GEQUAL,
            .Always       => c.GL_ALWAYS,
        };
    }
    fn me_to_gl_blendfac(fac: zrend.BlendFactor) c.GLenum {
        return switch(fac) {
            .Zero        => c.GL_ZERO,
            .One         => c.GL_ONE,
            .SrcColor    => c.GL_SRC_COLOR,
            .InvSrcColor => c.GL_ONE_MINUS_SRC_COLOR,
            .DstColor    => c.GL_DST_COLOR,
            .InvDstColor => c.GL_ONE_MINUS_DST_COLOR,
            .SrcAlpha    => c.GL_SRC_ALPHA,
            .InvSrcAlpha => c.GL_ONE_MINUS_SRC_ALPHA,
            .DstAlpha    => c.GL_DST_ALPHA,
            .InvDstAlpha => c.GL_ONE_MINUS_DST_ALPHA,
        };
    }
    fn me_to_gl_blendeq(op: zrend.BlendOp) c.GLenum {
        return switch(op) {
            .Add         => c.GL_FUNC_ADD,
            .Subtract    => c.GL_FUNC_SUBTRACT,
            .RevSubtract => c.GL_FUNC_REVERSE_SUBTRACT,
            .Min         => c.GL_MIN,
            .Max         => c.GL_MAX,
        };
    }
    fn me_to_gl_bool(cond: bool) c.GLboolean {
        if (cond) return c.GL_TRUE;
        return c.GL_FALSE;
    }
    fn me_to_gl_vert_fmt(fmt: zrend.VertexFormat) c.GLenum {
        _ = fmt;
        return c.GL_FLOAT; // for now
    }
    fn me_vert_fmt_get_count(fmt: zrend.VertexFormat) c.GLint {
        return switch(fmt) {
            .Float   => 1,
            .Vector2 => 2,
            .Vector3 => 3,
            .Vector4 => 4,
        };
    }
    fn me_to_gl_buffer_type(t: zrend.BufferType) c.GLenum {
        return switch(t) {
            .Vertex, .Instance => c.GL_ARRAY_BUFFER,
            .Index             => c.GL_ELEMENT_ARRAY_BUFFER,
            .Uniform           => c.GL_UNIFORM_BUFFER,
            .Storage           => c.GL_SHADER_STORAGE_BUFFER,
        };
    }
    fn me_to_gl_topology(top: zrend.Topology) c.GLenum {
        return switch(top) {
            .Points => c.GL_POINTS,
            .Lines => c.GL_LINES,
            .LineStrip => c.GL_LINE_STRIP,
            .Triangles => c.GL_TRIANGLES,
            .TriangleStrip => c.GL_TRIANGLE_STRIP,
            .TriangleFan => c.GL_TRIANGLE_FAN,
        };
    }
    fn me_to_gl_texture_fmt(fmt: zrend.TextureFormat) _gl_tex_fmt {
        return switch(fmt) {
            .Rgba8 => .{
                .internal = c.GL_RGBA8,
                .format   = c.GL_RGBA,
                .type     = c.GL_UNSIGNED_BYTE,
                },
            .Rgb8 => .{
                .internal = c.GL_RGB8,
                .format   = c.GL_RGB,
                .type     = c.GL_UNSIGNED_BYTE,
                },
            .R8 => .{
                .internal = c.GL_R8,
                .format   = c.GL_RED,
                .type     = c.GL_UNSIGNED_BYTE,
                },
            .Rgba16f => .{
                .internal = c.GL_RGBA16F,
                .format   = c.GL_RGBA,
                .type     = c.GL_HALF_FLOAT,
                },
            .Rgb16f => .{
                .internal = c.GL_RGB16F,
                .format   = c.GL_RGB,
                .type     = c.GL_HALF_FLOAT,
                },
            .R16f => .{
                .internal = c.GL_R16F,
                .format   = c.GL_RED,
                .type     = c.GL_HALF_FLOAT,
                },
            .Rgba32f => .{
                .internal = c.GL_RGBA32F,
                .format   = c.GL_RGBA,
                .type     = c.GL_FLOAT,
                },
            .Rgb32f => .{
                .internal = c.GL_RGB32F,
                .format   = c.GL_RGB,
                .type     = c.GL_FLOAT,
                },
            .R32f => .{
                .internal = c.GL_R32F,
                .format   = c.GL_RED,
                .type     = c.GL_FLOAT,
                },
            .Depth24 => .{
                .internal = c.GL_DEPTH_COMPONENT24,
                .format   = c.GL_DEPTH_COMPONENT,
                .type     = c.GL_UNSIGNED_INT,
                },
            .Depth32f => .{
                .internal = c.GL_DEPTH_COMPONENT32F,
                .format   = c.GL_DEPTH_COMPONENT,
                .type     = c.GL_FLOAT,
            },
            .Depth24Stencil8 => .{
                .internal = c.GL_DEPTH24_STENCIL8,
                .format   = c.GL_DEPTH_STENCIL,
                .type     = c.GL_UNSIGNED_INT_24_8,
                },
            .Depth32fStencil8 => .{
                .internal = c.GL_DEPTH32F_STENCIL8,
                .format   = c.GL_DEPTH_STENCIL,
                .type     = c.GL_FLOAT_32_UNSIGNED_INT_24_8_REV,
                },
        };
    }
    fn me_to_gl_texturesampling(samp: zrend.TextureSampling) c.GLenum {
        return switch(samp) {
            .Nearest => c.GL_NEAREST,
            .Linear  => c.GL_LINEAR,
        };
    }
    fn me_to_gl_buffer_usage(use: zrend.BufferUsage) c.GLenum {
        return switch(use) {
            .Dynamic => c.GL_DYNAMIC_DRAW,
            .Static => c.GL_STATIC_DRAW,
        };
    }
    fn me_to_gl_texture_type(tt: zrend.TextureType) c.GLenum {
        return switch(tt) {
            .Tex2D => c.GL_TEXTURE_2D,
            //.Tex3D => c.GL_TEXTURE_3D,
        };
    }
    fn me_to_gl_texture_wrap(wrap: zrend.TextureWrap) c.GLenum {
        return switch(wrap) {
            .Repeat => c.GL_REPEAT,
        };
    }

    const _gl_tex_fmt = struct{
        internal: c.GLint,
        format:   c.GLenum,
        type:     c.GLenum,
    };

    fn update_buffer(self: *zrend.Impl, buffer: *zrend.Buffer, data: []const u8) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        const targ = me_to_gl_buffer_type(buffer.desc.type);
        ts.gl.bindBuffer(targ, buffer.id);
        if (data.len > buffer.desc.size) {
            ts.gl.bufferData(targ, @intCast(data.len), data.ptr, c.GL_DYNAMIC_DRAW);
            buffer.desc.size = data.len;
        } else
            ts.gl.bufferSubData(targ, 0, @intCast(data.len), data.ptr);
        ts.gl.bindBuffer(targ, 0);
    }

    fn bind_pipeline(self: *zrend.Impl, pipeline: *zrend.Pipeline) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));
        const pln = pipeline;

        ts.gl.useProgram(pln.id);

        if (pln.desc.cull_mode != .None) {
            ts.gl.enable(c.GL_CULL_FACE);
            ts.gl.cullFace(me_to_gl_cullmode(pln.desc.cull_mode));
        } else
            ts.gl.disable(c.GL_CULL_FACE);

        if (pln.desc.depth_test) {
            ts.gl.enable(c.GL_DEPTH_TEST);
            ts.gl.depthFunc(me_to_gl_cmpop(pln.desc.depth_compare));
            ts.gl.depthMask(me_to_gl_bool(pln.desc.depth_write));
        } else {
            ts.gl.disable(c.GL_DEPTH_TEST);
            ts.gl.depthMask(c.GL_FALSE);
        }

        if (pln.desc.blend) |b| {
            ts.gl.enable(c.GL_BLEND);

            ts.gl.blendFuncSeparate(
                me_to_gl_blendfac(b.src_color),
                me_to_gl_blendfac(b.dst_color),
                me_to_gl_blendfac(b.src_alpha),
                me_to_gl_blendfac(b.dst_alpha),
                );
            ts.gl.blendEquationSeparate(
                me_to_gl_blendeq(b.color_op),
                me_to_gl_blendeq(b.alpha_op),
                );
        } else
            ts.gl.disable(c.GL_BLEND);

        if (pln.desc.vertex_layout_desc) |lay| {
            for (lay.attrs) |a| {
                ts.gl.enableVertexAttribArray(a.location);
                ts.gl.vertexAttribPointer(
                    a.location,
                    me_vert_fmt_get_count(a.format),
                    me_to_gl_vert_fmt(a.format),
                    c.GL_FALSE,
                    @intCast(lay.stride),
                    @ptrFromInt(a.offset),
                    );

                if (lay.type == .Vertex) {
                    ts.gl.vertexAttribDivisor(a.location, 0);
                } else
                    ts.gl.vertexAttribDivisor(a.location, 1);
            }
        }

        ts.cur_pipe = pln;
    }
    fn bind_buffer(self: *zrend.Impl, buffer: *zrend.Buffer, slot: u32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        const target = me_to_gl_buffer_type(buffer.desc.type);
        ts.gl.bindBuffer(target, buffer.id);

        if (buffer.desc.type == .Uniform or buffer.desc.type == .Storage)
            ts.gl.bindBufferBase(target, slot, buffer.id);

        if (buffer.desc.type == .Index)
            ts.cur_index_buf = buffer;
    }
    fn bind_texture(self: *zrend.Impl, texture: *zrend.Texture, slot: u32, location: u32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        ts.gl.activeTexture(@as(c_uint, @intCast(c.GL_TEXTURE0)) + @as(c_uint, @intCast(slot)));
        ts.gl.bindTexture(c.GL_TEXTURE_2D, texture.id); // TODO: change c.GL_TEXTURE_2D to convfmt from tex
        ts.gl.uniform1i(@intCast(location), @intCast(slot));
    }

    fn draw(self: *zrend.Impl, vertex_count: u32, instance_count: u32) void {
        const ts: *Impl = @ptrCast(@alignCast(self.act));

        if (instance_count == 0) return;

        const top = me_to_gl_topology(ts.cur_pipe.desc.topology);

        ts.gl.bindVertexArray(ts.dummy_vao);

        if (ts.cur_index_buf) |ib| {
            ts.gl.drawElementsInstanced(
                top, 
                @intCast(ib.desc.size / @sizeOf(u32)), 
                c.GL_UNSIGNED_INT, 
                null, // dont know if this works
                @intCast(instance_count)
                );
        } else
            ts.gl.drawArraysInstanced(top, 0, @intCast(vertex_count), @intCast(instance_count));
    }
};
