const std = @import("std");

pub fn build(b: *std.Build) void {
    const lib_name = "cc-wc-core";

    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib_module = b.addModule(lib_name, .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const lib = b.addLibrary(.{
        .name = lib_name,
        .root_module = lib_module,
        .linkage = .static,
    });

    b.installArtifact(lib);

    const lib_internal_name = "cc-wc-core-internal";
    const lib_internal_module = b.addModule(lib_internal_name, .{
        .root_source_file = b.path("src/root_internal.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_internal_module.addImport(lib_internal_name, lib_internal_module);
    lib.root_module.addImport(lib_internal_name, lib_internal_module);

    const lib_unit_tests = b.addTest(.{
        .root_module = lib_internal_module,
    });

    const run_lib_unit_tests = b.addRunArtifact(lib_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_lib_unit_tests.step);
}
