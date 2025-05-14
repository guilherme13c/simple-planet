const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .valgrind = true,
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "simple-planet",
        .root_module = exe_mod,
    });

    exe.addCSourceFile(.{
        .file = b.path("src/glad/glad.c"),
        .language = .c,
    });

    exe.linkLibC();
    exe.linkSystemLibrary("GL");
    exe.linkSystemLibrary("glfw3");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_exe_unit_tests.step);
}
