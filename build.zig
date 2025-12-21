const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const z_goop = b.createModule(.{
        .root_source_file = b.path("engine/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });
    z_goop.addAnonymousImport("zigimg", .{ .root_source_file = b.path("engine/deps/zigimg/zigimg.zig"), });

    const graah = b.createModule(.{
        .root_source_file = b.path("engine/graah/root.zig"),
        .target = target,
        .optimize = optimize,
    }); graah.addImport("z_goop", z_goop);

    // backends
    // plat
        const bplat_z_glfw = b.createModule(.{
            .root_source_file = b.path("backends/plat/glfw/glfw.zig"),
            .target = target,
            .optimize = optimize,
        });

        bplat_z_glfw.addImport("z_goop", z_goop);
        bplat_z_glfw.addIncludePath(.{ .cwd_relative = "backends/plat/glfw/" });
    // rend
        const brend_z_gl = b.createModule(.{
            .root_source_file = b.path("backends/rend/gl/gl.zig"),
            .target = target,
            .optimize = optimize,
        });

        brend_z_gl.addImport("z_goop", z_goop);

    const ex_window = b.addExecutable(.{
        .name = "window",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/window/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const ex_triangle = b.addExecutable(.{
        .name = "triangle",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/triangle/main.zig"),
            .target = target,
            .optimize = optimize,
        })
    });

    const ex_texture = b.addExecutable(.{
        .name = "texture",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/texture/main.zig"),
            .target = target,
            .optimize = optimize,
        })
    }); ex_texture.addIncludePath(.{ .cwd_relative = "examples/texture/" });

    const ex_graah = b.addExecutable(.{
        .name = "graah",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/graah/main.zig"),
            .target = target,
            .optimize = optimize,
        })
    });

    const examps = [_]*const *std.Build.Step.Compile{
        &ex_window,
        &ex_triangle,
        &ex_texture,
        &ex_graah,
    };

    const run_step = b.step("run", "run an example");

    const ex_name = if (b.args) |args|
        if (args.len > 0) args[0] else null
        else null;

    for (examps) |ex| {
        ex.*.linkLibC();
        //ex.*.addIncludePath(.{ .cwd_relative = "." });
        ex.*.root_module.addImport("z_goop", z_goop);
            { ex.*.root_module.addImport("graah", graah);
            } { ex.*.root_module.addImport("z_glfw", bplat_z_glfw);
                ex.*.linkSystemLibrary("glfw");
                if (builtin.os.tag == .linux) {
                    ex.*.linkSystemLibrary("X11");
                    ex.*.linkSystemLibrary("Xrandr");
                    ex.*.linkSystemLibrary("Xi");
                    ex.*.linkSystemLibrary("Xcursor");
                    ex.*.linkSystemLibrary("Xinerama");
                    ex.*.linkSystemLibrary("pthread");
                    ex.*.linkSystemLibrary("dl");
                    ex.*.linkSystemLibrary("m");
                }
            } { ex.*.root_module.addImport("z_gl", brend_z_gl);
                
            }

        b.installArtifact(ex.*);

        if (ex_name) |name| {
            if (std.mem.eql(u8, name, ex.*.name)) {
                const run_cmd = b.addRunArtifact(ex.*);
                run_cmd.step.dependOn(b.getInstallStep());

                if (b.args) |args| {
                    if (args.len > 1)
                        run_cmd.addArgs(args[1..]);
                }

                run_step.dependOn(&run_cmd.step);
            }
        }

        //const run_cmd = b.addRunArtifact(ex.*);
        //run_cmd.step.dependOn(b.getInstallStep());

        //if (b.args) |args|
        //    run_cmd.addArgs(args);

        //if (run_step) |step| {
        //    step.dependOn(&run_cmd.step);
        //} else {
        //    run_step = b.step("run", "run the examples");
        //    run_step.?.*.dependOn(&run_cmd.step);
            //b.step("run", "run the app").dependOn(&run_cmd.step);
        //}
    }
}
