const std = @import("std");
const zg = @import("z_goop");
const zrend = zg.rend;
const zmath = zg.math;
const Vec2 = zmath.Vec2;
const Vec3 = zmath.Vec3;
const Vec4 = zmath.Vec4;
const Mat4 = zmath.Mat4;

pub const Texture = struct{
    tex: zrend.Texture,
    width: u32,
    height: u32,
    img: zg.data.img.Rgba8,

    pub fn delete(self: *Texture) void {
        state.r.delete_texture(&self.tex);
        self.img.deinit(state.alloc);
    }
};

pub fn make_tex(data: []const u8) !Texture {
    var t = Texture{ .tex = undefined, .width = undefined, .height = undefined, .img = undefined };
    t.img = try zg.data.img.load_rgba8(state.alloc, data);
    t.width = t.img.width;
    t.height = t.img.height;
    t.tex = try state.r.make_texture(.{
        .width = @intCast(t.width),
        .height = @intCast(t.height),
    }, t.img.data);
    return t;
}

pub const Framebuffer = struct{
    fb: zrend.Framebuffer,
    width: u32,
    height: u32,
    tex: [2]zrend.Texture, // 0 is for color, 1 is for depth

    pub fn delete(self: *Framebuffer) void {
        state.r.delete_texture(&self.tex[0]);
        state.r.delete_texture(&self.tex[1]);
        state.r.delete_framebuffer(&self.fb);
    }
};

pub fn make_fb(width: u32, height: u32) !Framebuffer {
    var frb = Framebuffer{ .fb = undefined, .width = width, .height = height, .tex = undefined };
    
    frb.tex[0] = try state.r.make_texture(.{
        .width = width,
        .height = height,
        .usage = .Both,
    }, null);

    frb.tex[1] = try state.r.make_texture(.{
        .width = width,
        .height = height,
        .usage = .Target,
        .fmt = .Depth24,
    }, null);

    frb.fb = try state.r.make_framebuffer(.{
        .colors = &[_]*zrend.Texture{ &frb.tex[0] },
        .depth = &frb.tex[1],
        .width = width,
        .height = height,
    });

    return frb;
}

var state: struct{
    arena: std.heap.ArenaAllocator = undefined,
    alloc: std.mem.Allocator       = undefined,

    sh: struct{
        rect_pln: zrend.Pipeline = undefined,
        rect_vert: zrend.Shader  = undefined,
        rect_frag: zrend.Shader  = undefined,
        rect_ubo: zrend.Buffer   = undefined,

        tex_pln: zrend.Pipeline = undefined,
        tex_vert: zrend.Shader  = undefined,
        tex_frag: zrend.Shader  = undefined,
        tex_ubo: zrend.Buffer   = undefined,
    } = .{},

    r: *zrend.Impl = undefined,
} = .{};

// shd = shorthand, not shader
const shd = struct{
    pub fn basic_pipeline(vert: [*:0]const u8, frag: [*:0]const u8, o_pln: *zrend.Pipeline, o_vert: *zrend.Shader, o_frag: *zrend.Shader) !void {
        o_vert.* = try state.r.make_shader(.{
            .type = .Vertex,
            .source = vert,
        });

        o_frag.* = try state.r.make_shader(.{
            .type = .Fragment,
            .source = frag,
        });

        o_pln.* = try state.r.make_pipeline(.{
            .vertex_shader = o_vert,
            .fragment_shader = o_frag,
            .vertex_layout_desc = null,
        });
    }

    pub fn basic_ubo() !zrend.Buffer {
        return try state.r.make_buffer(.{
            .type = .Uniform,
            .usage = .Dynamic,
            .size = @sizeOf(f32), // doesent matter the size, itll resize itself on update, just cant be 0
        }, null);
    }
};

pub fn init(desc: struct{ 
    rend_impl: *zrend.Impl 
}) !void {
    state.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    state.alloc = state.arena.allocator();

    state.r = desc.rend_impl;

    try shd.basic_pipeline(@embedFile("shaders/rect.vert"), @embedFile("shaders/rect.frag"), 
        &state.sh.rect_pln, &state.sh.rect_vert, &state.sh.rect_frag);
    state.sh.rect_ubo = try shd.basic_ubo();

    try shd.basic_pipeline(@embedFile("shaders/tex.vert"), @embedFile("shaders/tex.frag"), 
        &state.sh.tex_pln, &state.sh.tex_vert, &state.sh.tex_frag);
    state.sh.tex_ubo = try shd.basic_ubo();
}

pub fn deinit() void {
    state.r.delete_buffer(&state.sh.tex_ubo);
    state.r.delete_shader(&state.sh.tex_vert);
    state.r.delete_shader(&state.sh.tex_frag);
    state.r.delete_pipeline(&state.sh.tex_pln);

    state.r.delete_buffer(&state.sh.rect_ubo);
    state.r.delete_shader(&state.sh.rect_vert);
    state.r.delete_shader(&state.sh.rect_frag);
    state.r.delete_pipeline(&state.sh.rect_pln);

    state.arena.deinit();
}


pub fn clear(r: f32, g: f32, b: f32, a: f32, framebuffer: ?*Framebuffer) void {
    state.r.bind_framebuffer(if (framebuffer) |_| @constCast(&framebuffer.?.fb) else null);

    state.r.clear(.{ r,g,b,a });
}

pub fn rect(desc: struct{ pos: Vec2, size: Vec2, col: Vec4, transf: Mat4 = Mat4.identity(), proj: ?Mat4 = null, targ: ?*Framebuffer = null }) void {
    const scrn = if (desc.targ) |t| Vec2{.x=@floatFromInt(t.width),.y=@floatFromInt(t.height)} else Vec2{.x=@floatFromInt(state.r.width),.y=@floatFromInt(state.r.height)};
    const proj = desc.proj orelse if (desc.targ) Mat4.ortho(0, scrn.x, 0, scrn.y, 0,1) else Mat4.ortho(0, scrn.x, scrn.y, 0, 0,1);
    state.r.bind_pipeline(&state.sh.rect_pln);
    state.r.update_buffer(&state.sh.rect_ubo, std.mem.sliceAsBytes(&[_]f32{ 
        desc.pos.x,desc.pos.y, 
        desc.size.x,desc.size.y, 
        desc.col.x,desc.col.y,desc.col.z,desc.col.w, 
    } ++ desc.transf.data ++ proj.data));
    state.r.bind_buffer(&state.sh.rect_ubo, 0);
    state.r.bind_framebuffer(if (desc.targ) |_| @constCast(&desc.targ.?.fb) else null);
    state.r.draw(6,1);
}

pub fn tex(desc: struct{ pos: Vec2, size: Vec2, col: Vec4 = Vec4{.x=1,.y=1,.z=1,.w=1}, sample: ?Vec4 = null, tex: *Texture, transf: Mat4 = Mat4.identity(), proj: ?Mat4 = null, targ: ?*Framebuffer = null }) void {
    const scrn = if (desc.targ) |t| Vec2{.x=@floatFromInt(t.width),.y=@floatFromInt(t.height)} else Vec2{.x=@floatFromInt(state.r.width),.y=@floatFromInt(state.r.height)};
    const proj = desc.proj orelse if (desc.targ) Mat4.ortho(0, scrn.x, 0, scrn.y, 0,1) else Mat4.ortho(0, scrn.x, scrn.y, 0, 0,1);
    var samp: Vec4 = undefined;
    if (desc.sample) |s| {
        samp = Vec4{
            .x = s.x / @as(f32, @floatFromInt(desc.tex.width)),
            .y = s.y / @as(f32, @floatFromInt(desc.tex.height)),
            .z = s.z / @as(f32, @floatFromInt(desc.tex.width)),
            .w = s.w / @as(f32, @floatFromInt(desc.tex.height)),
            };
    } else samp = Vec4{.x=0,.y=0,.z=1,.w=1};
    state.r.bind_pipeline(&state.sh.tex_pln);
    state.r.update_buffer(&state.sh.tex_ubo, std.mem.sliceAsBytes(&[_]f32{ 
        desc.pos.x,desc.pos.y, 
        desc.size.x,desc.size.y, 
        desc.col.x,desc.col.y,desc.col.z,desc.col.w, 
        samp.x, samp.y, samp.z, samp.w,
    } ++ desc.transf.data ++ proj.data));
    state.r.bind_buffer(&state.sh.tex_ubo, 0);
    state.r.bind_texture(&desc.tex.tex, 0,0);
    state.r.bind_framebuffer(if (desc.targ) |_| @constCast(&desc.targ.?.fb) else null);
    state.r.draw(6,1);
}

pub fn fb(desc: struct{ pos: Vec2 = Vec2{.x=0,.y=0}, size: ?Vec2 = null, col: Vec4 = Vec4{.x=1,.y=1,.z=1,.w=1}, sample: ?Vec4 = null, in: *Framebuffer, transf: Mat4 = Mat4.identity(), proj: ?Mat4 = null, out: ?Framebuffer = null }) void {
    const scrn = if (desc.out) |t| Vec2{.x=@floatFromInt(t.width),.y=@floatFromInt(t.height)} else Vec2{.x=@floatFromInt(state.r.width),.y=@floatFromInt(state.r.height)};
    const proj = desc.proj orelse if (desc.out) Mat4.ortho(0, scrn.x, 0, scrn.y, 0,1) else Mat4.ortho(0, scrn.x, scrn.y, 0, 0,1);
    var samp: Vec4 = undefined;
    if (desc.sample) |s| {
        samp = Vec4{
            .x = s.x / @as(f32, @floatFromInt(desc.in.width)),
            .y = s.y / @as(f32, @floatFromInt(desc.in.height)),
            .z = s.z / @as(f32, @floatFromInt(desc.in.width)),
            .w = s.w / @as(f32, @floatFromInt(desc.in.height)),
            };
    } else samp = Vec4{.x=0,.y=0,.z=1,.w=1};
    const size = desc.size orelse if (desc.out) |o| Vec2{.x=@floatFromInt(o.width), .y=@floatFromInt(o.height)} else Vec2{.x=@floatFromInt(state.r.width), .y=@floatFromInt(state.r.height)}; // shit ass line
    state.r.bind_pipeline(&state.sh.tex_pln);
    state.r.update_buffer(&state.sh.tex_ubo, std.mem.sliceAsBytes(&[_]f32{ 
        desc.pos.x,desc.pos.y, 
        size.x,size.y, 
        desc.col.x,desc.col.y,desc.col.z,desc.col.w, 
        samp.x, samp.y, samp.z, samp.w,
    } ++ desc.transf.data ++ proj.data));
    state.r.bind_buffer(&state.sh.tex_ubo, 0);
    state.r.bind_texture(&desc.in.tex[0], 0,0);
    state.r.bind_framebuffer(if (desc.out) |_| @constCast(&desc.out.?.fb) else null);
    state.r.draw(6,1);
}
