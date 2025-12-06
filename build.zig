const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const z_goop = b.createModule(.{
        .root_source_file = b.path("engine/src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const ex_window = b.addExecutable(.{
        .name = "window",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/window/main.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });
    ex_window.root_module.addImport("z_goop", z_goop);

    const examps = [_]*const *std.Build.Step.Compile{
        &ex_window
    };

    for (examps) |ex| {
        b.installArtifact(ex.*);

        const run_cmd = b.addRunArtifact(ex.*);
        run_cmd.step.dependOn(b.getInstallStep());

        if (b.args) |args|
            run_cmd.addArgs(args);

        b.step("run", "run the app").dependOn(&run_cmd.step);
    }
}
