const std = @import("std");

const targets: []const std.zig.CrossTarget = &.{
    .{ .cpu_arch = .aarch64, .os_tag = .macos },
    //target=aarch64-linux-gnu.2.31 (RPI)
    .{ .cpu_arch = .aarch64, .os_tag = .linux, .abi = .gnu, .glibc_version = 2.31 },
};

pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.

    //0.13
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});
    const exe = b.addExecutable(.{
        .name = "unbeatable",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // const default_build = [_][]const u8{"-std=c99"};
    const default_build = [_][]const u8{"-std=gnu99"};
    switch (target.result.os.tag) {
        .macos => {
            std.debug.print("Buildning MACOS\n", .{});
            exe.addIncludePath(.{ .cwd_relative = "/opt/homebrew/include" });
            exe.addLibraryPath(.{ .cwd_relative = "/opt/homebrew/lib" });
            exe.linkSystemLibrary("raylib");
            exe.linkSystemLibrary("sndfile");
        },
        .linux => {
            std.debug.print("Buildning LINUX\n", .{});
            //exe.addIncludePath(b.path("ray5/include"));
            //exe.addLibraryPath(b.path("ray5/lib"));
            exe.addIncludePath(b.path("lib/linux/include"));
            exe.addLibraryPath(b.path("lib/linux/lib"));
            exe.linkSystemLibrary2("raylib", .{ .use_pkg_config = .no });
            //exe.addObjectFile(.{ .cwd_relative = "./lib/linux/lib/libraylib.a" });
        },
        else => {
            @panic("Unsupported OS");
        },
    }
    //exe.linkSystemLibrary("atomic");
    exe.addIncludePath(b.path("timer"));
    exe.addCSourceFile(.{ .file = b.path("timer/timer.c"), .flags = &default_build });
    exe.addIncludePath(b.path("miniaudio/split"));
    exe.addCSourceFile(.{ .file = b.path("miniaudio/split/miniaudio.c"), .flags = &default_build });
    exe.addIncludePath(b.path("raylibwrapper"));
    exe.addCSourceFile(.{ .file = b.path("raylibwrapper/raylibwrapper.c"), .flags = &default_build });
    exe.addIncludePath(b.path("multifx"));
    exe.linkLibC();
    b.installArtifact(exe);
}
