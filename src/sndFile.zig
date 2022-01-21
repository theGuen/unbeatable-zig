const std = @import("std");
const sf = @cImport(@cInclude("sndfile.h"));

const Info = extern struct {
    frames: i64,
    samplerate: c_int,
    channels: c_int,
    format: c_int,
    sections: c_int,
    seekable: c_int,
};
pub fn loadAudioFile(allocator:std.mem.Allocator,inFileName: []const u8) !*[]f32{
    var sndFileInfo = try std.heap.c_allocator.create(Info);
    defer std.heap.c_allocator.destroy(sndFileInfo);

    var sndFileInfoPtr = @ptrCast([*c] sf.SF_INFO, sndFileInfo);
    const inFile = sf.sf_open(inFileName.ptr, sf.SFM_READ, sndFileInfoPtr);
    defer _ =sf.sf_close(inFile);
    std.debug.print("Frames / Channels: {d} / {d}\n", .{sndFileInfo.frames,sndFileInfo.channels});

    var mybuffer: []f32 = undefined;
    const arrayLen = @intCast(usize, sndFileInfo.frames*sndFileInfo.channels);
    mybuffer = try allocator.alloc(f32, arrayLen);
    std.debug.print("Samples allocated: {d} / {d}\n", .{arrayLen,mybuffer.len});

    const read = sf.sf_readf_float(inFile, mybuffer.ptr, sndFileInfo.frames) ;
    std.debug.print("Frames read:{d}\n", .{read});
    return &mybuffer;
}