const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    //0.10
    //const target = b.standardTargetOptions(.{});
    //const mode = b.standardReleaseOptions();

    //0.11
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    //const miniaudio = b.addStaticLibrary("miniaudio", null);
    //miniaudio.setTarget(target);
    //miniaudio.setBuildMode(mode);
    //miniaudio.linkLibC();
    //miniaudio.force_pic = true;
    //miniaudio.addCSourceFiles(&.{
    //    "miniaudio/miniaudio.c",
    //}, &.{
    //    "-Wall"
    //});

    //0.11.0
    const exe = b.addExecutable(.{
        .name = "unbeatable",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    const default_build = [_][]const u8{"-std=c99"};
    exe.single_threaded = b.option(bool, "single-threaded", "Build artifacts that run in single threaded mode") orelse false;
    exe.addIncludePath(.{ .path = "/opt/homebrew/include" });
    exe.addLibraryPath(.{ .path = "/opt/homebrew/lib" });
    exe.linkSystemLibrary("raylib");
    exe.addIncludePath(.{ .path = "miniaudio/split" });
    exe.addCSourceFile(.{ .file = .{ .path = "miniaudio/split/miniaudio.c" }, .flags = &default_build });
    exe.addIncludePath(.{ .path = "raylibwrapper" });
    exe.addCSourceFile(.{ .file = .{ .path = "raylibwrapper/raylibwrapper.c" }, .flags = &default_build });
    exe.addIncludePath(.{ .path = "multifx" });
    exe.linkLibC();
    b.installArtifact(exe);

    //0.10.0
    //const exe = b.addExecutable("unbeatable-zig", "src/main.zig");
    //exe.use_stage1 = true;
    //exe.setTarget(target);
    //exe.setBuildMode(mode);

    //exe.single_threaded = b.option(bool, "single-threaded", "Build artifacts that run in single threaded mode") orelse false;
    //exe.addIncludePath("/opt/homebrew/include");
    //exe.addLibraryPath("/opt/homebrew/lib");

    ////exe.addIncludePath("/raylib-4.2.0/src");
    ////exe.addLibraryPath("/raylib-4.2.0/src/zig-out/lib");

    ////exe.linkSystemLibrary("soundio");
    ////exe.linkSystemLibrary("sndfile");
    //exe.linkSystemLibrary("raylib");
    //exe.addIncludePath("miniaudio/split");
    //exe.addCSourceFile("miniaudio/split/miniaudio.c", &[_][]const u8{});
    //exe.addIncludePath("raylibwrapper");
    //exe.addCSourceFile("raylibwrapper/raylibwrapper.c", &[_][]const u8{});
    //exe.addIncludePath("multifx");
    //exe.linkLibC();
    //exe.install();
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
