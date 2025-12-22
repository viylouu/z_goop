const std = @import("std");
const zg = @import("z_goop");
const zrend = zg.rend;
const zmath = zg.math;
const Vec2 = zmath.Vec2;
const Vec3 = zmath.Vec3;
const Vec4 = zmath.Vec4;

var state: struct{
    arena: std.heap.ArenaAllocator = undefined,
    alloc: std.mem.Allocator       = undefined,

    sh: struct{
        rect_pln: zrend.Pipeline = undefined,
        rect_vert: zrend.Shader  = undefined,
        rect_frag: zrend.Shader  = undefined,
        rect_ubo: zrend.Buffer   = undefined,
    } = .{},

    r: *zrend.Impl = undefined,
} = .{};

pub fn init(desc: struct{ 
    rend_impl: *zrend.Impl 
}) !void {
    state.arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    state.alloc = state.arena.allocator();

    state.r = desc.rend_impl;

    state.sh.rect_vert = try state.r.make_shader(.{
        .type = .Vertex,
        .source = @embedFile("shaders/rect.vert"),
    });

    state.sh.rect_frag = try state.r.make_shader(.{
        .type = .Fragment,
        .source = @embedFile("shaders/rect.frag"),
    });

    state.sh.rect_pln = try state.r.make_pipeline(.{
        .vertex_shader = &state.sh.rect_vert,
        .fragment_shader = &state.sh.rect_frag,
        .vertex_layout_desc = null,
    });

    state.sh.rect_ubo = try state.r.make_buffer(.{
        .type = .Uniform,
        .usage = .Dynamic,
        .size = @sizeOf(f32)*2*2 + @sizeOf(f32)*4,
    }, null);
}

pub fn deinit() void {
    state.r.delete_buffer(&state.sh.rect_ubo);
    state.r.delete_shader(&state.sh.rect_vert);
    state.r.delete_shader(&state.sh.rect_frag);
    state.r.delete_pipeline(&state.sh.rect_pln);

    state.arena.deinit();
}


pub fn clear(r: f32, g: f32, b: f32) void {
    state.r.clear(.{ r,g,b,1 });
}

pub fn rect(desc: struct{ pos: Vec2, size: Vec2, col: Vec4 }) void {
    state.r.bind_pipeline(&state.sh.rect_pln);
    state.r.update_buffer(&state.sh.rect_ubo, std.mem.sliceAsBytes(&[_]f32{ desc.pos.x,desc.pos.y, desc.size.x,desc.size.y, desc.col.x,desc.col.y,desc.col.z,desc.col.w, }));
    state.r.bind_buffer(&state.sh.rect_ubo, 0);
    state.r.draw(6,1);
}
