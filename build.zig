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

    // backends
        const b_z_glfw = b.createModule(.{
            .root_source_file = b.path("backends/plat/glfw/glfw.zig"),
            .target = target,
            .optimize = optimize,
        });

        b_z_glfw.addImport("z_goop", z_goop);

    const ex_window = b.addExecutable(.{
        .name = "window",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/window/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const examps = [_]*const *std.Build.Step.Compile{
        &ex_window
    };

    for (examps) |ex| {
        ex.*.root_module.addImport("z_goop", z_goop);
            { ex.*.root_module.addImport("z_glfw", b_z_glfw);
                ex.*.addIncludePath(b.path("backends/plat/glfw"));
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
            }

        b.installArtifact(ex.*);

        const run_cmd = b.addRunArtifact(ex.*);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args|
            run_cmd.addArgs(args);

        b.step("run", "run the app").dependOn(&run_cmd.step);
    }
}
