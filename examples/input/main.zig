const std = @import("std");

const zg = @import("z_goop");
const zplat = zg.plat;
const zrend = zg.rend;

const zglfw = @import("z_glfw");
const zgl = @import("z_gl");

const Game = struct{
    pub var p_impl: *zplat.Impl = undefined;
    pub var r_impl: *zrend.Impl = undefined;
    pub var tex_pln: zrend.Pipeline = undefined;
    pub var tex_ubo: zrend.Buffer = undefined;
    pub var tex: zrend.Texture = undefined;
    pub var img: zg.data.img.Rgba8 = undefined;
    pub var arena: std.heap.ArenaAllocator = undefined;
    pub var alloc: std.mem.Allocator = undefined;
    pub var x: f32 = 0;

    pub fn init() !void {
        arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
        alloc = arena.allocator();

        var tex_vert = try r_impl.make_shader(.{
            .type = .Vertex,
            .source = @embedFile("tex.vert"),
        });

        var tex_frag = try r_impl.make_shader(.{
            .type = .Fragment,
            .source = @embedFile("tex.frag"),
        });

        tex_pln = try r_impl.make_pipeline(.{
                .vertex_shader = &tex_vert,
                .fragment_shader = &tex_frag,
                .vertex_layout_desc = null,
            });

        tex_ubo = try r_impl.make_buffer(.{
            .type = .Uniform,
            .usage = .Dynamic,
            .size = @sizeOf(f32)*2,
        }, null);

        img = try zg.data.img.load_rgba8(alloc, @embedFile("tex.png"));

        tex = try r_impl.make_texture(.{
                .width = @intCast(img.width),
                .height = @intCast(img.height),
            }, img.data);
    }

    pub fn update(dt: f32) !void { 
        r_impl.clear(.{0,0,0,1});

        if (p_impl.is_key(.A)) x -= dt;
        if (p_impl.is_key(.D)) x += dt;

        r_impl.bind_pipeline(&tex_pln);
        r_impl.bind_texture(&tex, 0,0);
        r_impl.update_buffer(&tex_ubo, std.mem.sliceAsBytes(&[_]f32{ x, 0 }));
        r_impl.bind_buffer(&tex_ubo, 0);
        r_impl.draw(6,1);
    }

    pub fn exit() void {
        r_impl.delete_texture(&tex);
        img.deinit(alloc);
        r_impl.delete_buffer(&tex_ubo);
        r_impl.delete_shader(tex_pln.desc.vertex_shader);
        r_impl.delete_shader(tex_pln.desc.fragment_shader);
        r_impl.delete_pipeline(&tex_pln);

        arena.deinit();
    }
};

pub fn main() !void {
    Game.p_impl = &zglfw.impl;
    Game.r_impl = &zgl.impl;

    try zg.run(.{
        .plat_impl = Game.p_impl,
        .rend_impl = Game.r_impl,

        .init   = Game.init,
        .update = Game.update,
        .exit   = Game.exit,

        .title  = "texture",
        .width  = 800,
        .height = 600,
    });
}

