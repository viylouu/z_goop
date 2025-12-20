const std = @import("std");

const zg = @import("z_goop");
const zrend = zg.rend;

const zglfw = @import("z_glfw");
const zgl = @import("z_gl");

const Game = struct{
    pub var r_impl: *zrend.Impl = undefined;
    pub var tex_pln: zrend.Pipeline = undefined;
    pub var tex: zrend.Texture = undefined;

    pub fn init() !void {
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

        const width = 256;
        const height = 256;
        var img_data: [width * height * 4]u8 = undefined;

        var seed: u32 = 0x12345678;

        for (0..width*height*4-1) |i| {
            seed ^= seed << 13;
            seed ^= seed >> 17;
            seed ^= seed << 5;
            img_data[i] = @truncate(seed);
        }

        tex = try r_impl.make_texture(.{
                .width = @intCast(width),
                .height = @intCast(height)
            }, &img_data);
    }

    pub fn update(dt: f32) !void { 
        _ = dt;
        r_impl.clear(.{0,0,0,1});

        r_impl.bind_pipeline(&tex_pln);
        r_impl.bind_texture(&tex, 0,0);
        r_impl.draw(6,1);
    }

    pub fn exit() void {
        r_impl.delete_texture(&tex);
        r_impl.delete_shader(tex_pln.desc.vertex_shader);
        r_impl.delete_shader(tex_pln.desc.fragment_shader);
        r_impl.delete_pipeline(&tex_pln);
    }
};

pub fn main() !void {
    Game.r_impl = &zgl.impl;

    try zg.run(.{
        .plat_impl = &zglfw.impl,
        .rend_impl = Game.r_impl,

        .init   = Game.init,
        .update = Game.update,
        .exit   = Game.exit,

        .title  = "triangle",
        .width  = 800,
        .height = 600,
    });
}

