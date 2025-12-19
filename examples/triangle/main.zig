const std = @import("std");

const zg = @import("z_goop");
const zrend = zg.rend;

const zglfw = @import("z_glfw");
const zgl = @import("z_gl");

const Game = struct{
    pub var r_impl: *zrend.Impl = undefined;
    pub var tri_pln: zrend.Pipeline = undefined;

    pub fn init() !void {
        //std.debug.print("init!\n", .{});
        
        var tri_vert = try r_impl.make_shader(.{
            .type = .Vertex,
            .source = @embedFile("tri.vert"),
        });

        var tri_frag = try r_impl.make_shader(.{
            .type = .Fragment,
            .source = @embedFile("tri.frag"),
        });

        tri_pln = try r_impl.make_pipeline(.{
                .vertex_shader = &tri_vert,
                .fragment_shader = &tri_frag,
                .vertex_layout_desc = null,
            });
    }

    pub fn update(dt: f32) !void { 
        //std.debug.print("update! {d:.2} FPS\n", .{ 1.0/dt });
        _ = dt;
        r_impl.clear(.{0,0,0,1});

        r_impl.bind_pipeline(&tri_pln);
        r_impl.draw(3,1);
    }

    pub fn exit() void {
        //std.debug.print("exit!\n", .{});
    
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
