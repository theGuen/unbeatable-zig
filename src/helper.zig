const std = @import("std");
const process = std.process;
const ma = @import("miniaudio.zig");
const smplr = @import("sampler.zig");

pub fn loadCmdLineArgSamples(alloc: std.mem.Allocator, sampler: *smplr.Sampler) !void {
    var args = process.args();
    // skip my own exe name
    _ = args.skip();
    var i: usize = 0;
    while (true) {
        const arg1 = (try args.next(alloc) orelse {
            break;
        });
        var b = try ma.loadAudioFile(alloc, arg1);
        const split = try smplr.splitSample(alloc, b, b.len);
        sampler.load(split, i);
        i += 1;
        alloc.free(arg1);
    }
}

pub fn userInput(samplers: *smplr.Sampler) !void {
    while (true) {
        var buf: [1000]u8 = undefined;
        // We need a 0 terminated string... how unpleasant
        for (buf) |_, ii| buf[ii] = 0;
        const stdin = std.io.getStdIn().reader();
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            const bla: []u8 = user_input;
            if (ma.loadAudioFile(samplers.alloc, bla)) |b| {
                samplers.load(b);
            } else |err| {
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        }
    }
}

pub fn StringHasSuffix(string: []const u8, suffix: []const u8) bool {
    var retval = true;
    if (suffix.len > string.len) return false;
    for (suffix) |c, i| {
        retval = retval and (string[string.len - suffix.len + i] == c);
    }
    return retval;
}

pub fn StringConcat(alloc: std.mem.Allocator, first: []const u8, second: []const u8) ![]const u8 {
    const concatenated = try std.fmt.allocPrint(alloc, "{s}{s}", .{ first, second });
    return concatenated;
}

pub fn StringRemoveNullByte(alloc: std.mem.Allocator, first: []const u8) ![]const u8 {
    var retval: []u8 = undefined;
    if (first[first.len - 1] == 0) {
        retval = try alloc.alloc(u8, first.len - 1);
    } else {
        retval = try alloc.alloc(u8, first.len);
    }
    std.mem.copy(u8, retval[0..retval.len], first[0..retval.len]);
    return retval;
}

pub const DirEntry = struct { name: []u8, file: bool, path: []u8 };

pub fn readDirectory(alloc: std.mem.Allocator, path: []const u8) !std.ArrayList(DirEntry) {
    var content = std.ArrayList(DirEntry).init(alloc);
    var dir: std.fs.Dir = undefined;
    if (path[0] != '/') {
        dir = std.fs.cwd().openDir(path, .{ .iterate = true, .access_sub_paths = true }) catch return content;
    } else {
        const mPath = StringRemoveNullByte(alloc, path) catch return content;
        defer alloc.free(mPath);
        std.debug.print("ABS {s} {d}\n", .{ mPath, std.mem.indexOfScalar(u8, mPath, 0) });

        dir = std.fs.openDirAbsolute(mPath, .{ .iterate = true, .access_sub_paths = true }) catch return content;
    }
    const dirName = dir.realpathAlloc(alloc, "./") catch return content;

    var walker = dir.iterate();
    while (try walker.next()) |entry| {
        if (entry.kind == std.fs.File.Kind.Directory) {
            var dest = alloc.alloc(u8, entry.name.len + 1) catch return content;
            dest[entry.name.len] = 0;
            std.mem.copy(u8, dest[0..entry.name.len], entry.name[0..entry.name.len]);

            var destPath = alloc.alloc(u8, dirName.len + 1) catch return content;
            std.mem.copy(u8, destPath[0..dirName.len], dirName[0..dirName.len]);
            destPath[destPath.len - 1] = '/';
            content.append(DirEntry{ .name = dest, .file = false, .path = destPath }) catch return content;
        } else {
            if (StringHasSuffix(entry.name, ".wav") or StringHasSuffix(entry.name, ".mp3")) {
                var dest = alloc.alloc(u8, entry.name.len + 1) catch return content;
                std.mem.copy(u8, dest[0..entry.name.len], entry.name[0..entry.name.len]);
                dest[entry.name.len] = 0;

                var destPath = alloc.alloc(u8, dirName.len + 1) catch return content;
                std.mem.copy(u8, destPath[0..dirName.len], dirName[0..dirName.len]);
                destPath[destPath.len - 1] = '/';
                content.append(DirEntry{ .name = dest, .file = true, .path = destPath }) catch return content;
            }
        }
    }
    return content;
}
