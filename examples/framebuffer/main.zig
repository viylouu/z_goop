const std = @import("std");

const zg = @import("z_goop");
const zrend = zg.rend;

const zglfw = @import("z_glfw");
const zgl = @import("z_gl");

const Game = struct{
    pub var r_impl: *zrend.Impl = undefined;
    pub var tri_pln: zrend.Pipeline = undefined;
        pub var tri_vert: zrend.Shader = undefined;
        pub var tri_frag: zrend.Shader = undefined;
    pub var fb: zrend.Framebuffer = undefined;
    pub var fb_tex: zrend.Texture = undefined;
    pub var fb_pln: zrend.Pipeline = undefined;
        pub var fb_vert: zrend.Shader = undefined;
        pub var fb_frag: zrend.Shader = undefined;

    pub const width: u32 = 128;
    pub const height: u32 = 128;

    pub fn init() !void {
        tri_vert = try r_impl.make_shader(.{
            .type = .Vertex,
            .source = @embedFile("tri.vert"),
        });

        tri_frag = try r_impl.make_shader(.{
            .type = .Fragment,
            .source = @embedFile("tri.frag"),
        });

        tri_pln = try r_impl.make_pipeline(.{
                .vertex_shader = &tri_vert,
                .fragment_shader = &tri_frag,
                .vertex_layout_desc = null,
            });

        fb_tex = try r_impl.make_texture(.{
            .width = width,
            .height = height,
            .usage = .Both,
        }, null);

        fb = try r_impl.make_framebuffer(.{
            .colors = &[_]*zrend.Texture{ &fb_tex },
            .width = width,
            .height = height,
        });

        fb_vert = try r_impl.make_shader(.{
            .type = .Vertex,
            .source = @embedFile("fb.vert"),
        });

        fb_frag = try r_impl.make_shader(.{
            .type = .Fragment,
            .source = @embedFile("fb.frag"),
        });

        fb_pln = try r_impl.make_pipeline(.{
                .vertex_shader = &fb_vert,
                .fragment_shader = &fb_frag,
                .vertex_layout_desc = null,
            });
    }

    pub fn update(dt: f32) !void { 
        _ = dt;
        r_impl.clear(.{0,0,0,1});

        r_impl.bind_framebuffer(&fb);

        r_impl.bind_pipeline(&tri_pln);
        r_impl.draw(3,1);

        r_impl.bind_framebuffer(null);

        r_impl.bind_pipeline(&fb_pln);
        r_impl.bind_texture(&fb_tex, 0,0);
        r_impl.draw(6,1);
    }

    pub fn exit() void {
        r_impl.delete_shader(fb_pln.desc.vertex_shader);
        r_impl.delete_shader(fb_pln.desc.fragment_shader);
        r_impl.delete_pipeline(&fb_pln);
        r_impl.delete_framebuffer(&fb);
        r_impl.delete_texture(&fb_tex);
        r_impl.delete_shader(tri_pln.desc.vertex_shader);
        r_impl.delete_shader(tri_pln.desc.fragment_shader);
        r_impl.delete_pipeline(&tri_pln);
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
