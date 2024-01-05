const std = @import("std");

const targets: []const std.zig.CrossTarget = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    //target=aarch64-linux-gnu.2.31 (RPI)
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu, .glibc_version = 2.31 },
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.

    //0.11
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "unbeatable",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    // const default_build = [_][]const u8{"-std=c99"};
    const default_build = [_][]const u8{"-std=gnu99"};
    exe.single_threaded = b.option(bool, "single-threaded", "Build artifacts that run in single threaded mode") orelse false;
    switch (exe.target.toTarget().os.tag) {
        .macos => {
            exe.addIncludePath(.{ .path = "/opt/homebrew/include" });
            exe.addLibraryPath(.{ .path = "/opt/homebrew/lib" });
            exe.linkSystemLibrary("raylib");
            //exe.addIncludePath(.{ .path = "/Users/gs/Downloads/raylib-5.0_macos/include" });
            //exe.addLibraryPath(.{ .path = "/Users/gs/Downloads/raylib-5.0_macos/lib" });
            //exe.linkSystemLibraryName("raylib");
        },
        .linux => {
            exe.addIncludePath(.{ .path = "lib/linux/include" });
            exe.addLibraryPath(.{ .path = "lib/linux/lib" });
            exe.linkSystemLibraryName("raylib");
        },
        else => {
            @panic("Unsupported OS");
        },
    }

    exe.addIncludePath(.{ .path = "timer" });
    exe.addCSourceFile(.{ .file = .{ .path = "timer/timer.c" }, .flags = &default_build });
    exe.addIncludePath(.{ .path = "miniaudio/split" });
    exe.addCSourceFile(.{ .file = .{ .path = "miniaudio/split/miniaudio.c" }, .flags = &default_build });
    exe.addIncludePath(.{ .path = "raylibwrapper" });
    exe.addCSourceFile(.{ .file = .{ .path = "raylibwrapper/raylibwrapper.c" }, .flags = &default_build });
    exe.addIncludePath(.{ .path = "multifx" });
    exe.linkLibC();
    b.installArtifact(exe);

    ////const run_cmd = exe.run();
    ////run_cmd.step.dependOn(b.getInstallStep());
    ////if (b.args) |args| {
    ////    run_cmd.addArgs(args);
    ////}

    ////const run_step = b.step("run", "Run the app");
    ////run_step.dependOn(&run_cmd.step);

    ////const exe_tests = b.addTest("src/main.zig");
    ////exe_tests.setTarget(target);
    ////exe_tests.setBuildMode(mode);

    ////const test_step = b.step("test", "Run unit tests");
    ////test_step.dependOn(&exe_tests.step);
}
