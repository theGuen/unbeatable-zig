const std = @import("std");
const ma = @cImport(@cInclude("miniaudio.h"));
const mfx = @cImport(@cInclude("multifx22.h"));
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const settings = @import("settings.zig");

const mixerFunction = *const fn () [4]f32;
//pub var startAudioFrame: anyframe = undefined;
pub var allocator: std.mem.Allocator = undefined;
pub var mix: mixerFunction = undefined;
pub var fx: [*c]mfx.mydsp = undefined;
pub var recorder: *rcdr.Recorder = undefined;

pub fn init(anAudioAllocator: std.mem.Allocator, aMenuAllocator: std.mem.Allocator, aMixFunction: mixerFunction, aRecorder: *rcdr.Recorder) ![]ui.MenuItem {
    allocator = anAudioAllocator;
    mix = aMixFunction;
    recorder = aRecorder;

    fx = mfx.newmydsp();
    mfx.initmydsp(fx, settings.sampleRate);

    const uiGlue = try ui.newUIGlue();
    const uiGlue_c = @as([*c]mfx.UIGlue, @ptrCast(uiGlue));
    mfx.buildUserInterfacemydsp(fx, uiGlue_c);
    const items = try ui.MenuItemsFromUIGlue(aMenuAllocator, uiGlue);
    return items;
}

pub fn saveAudioFile(inFileName: []const u8, myBuffer: []f32) !void {
    const buffer = @as([*c]f32, @ptrCast(@alignCast(myBuffer)));
    var config = ma.ma_encoder_config_init(ma.ma_encoding_format_wav, ma.ma_format_f32, 2, settings.sampleRate);
    var encoder = std.mem.zeroes(ma.ma_encoder);
    var res = ma.ma_encoder_init_file(inFileName.ptr, &config, &encoder);
    defer ma.ma_encoder_uninit(&encoder);
    if (res != ma.MA_SUCCESS) {
        std.debug.print("Could not init encoder {s}: {d}\n", .{ inFileName, res });
        return error.Unknown;
    }
    //var pFramesWritten: c_ulonglong = 0;
    var pFramesWritten: usize = 0;
    res = ma.ma_encoder_write_pcm_frames(&encoder, buffer, myBuffer.len / 2, &pFramesWritten);
}

pub fn saveRecordedFile(inFileName: []const u8, list: std.ArrayList([]f32)) !void {
    var config = ma.ma_encoder_config_init(ma.ma_encoding_format_wav, ma.ma_format_f32, 2, settings.sampleRate);
    var encoder = std.mem.zeroes(ma.ma_encoder);
    const res = ma.ma_encoder_init_file(inFileName.ptr, &config, &encoder);
    defer ma.ma_encoder_uninit(&encoder);
    if (res != ma.MA_SUCCESS) {
        std.debug.print("Could not init encoder {s}: {d}\n", .{ inFileName, res });
        return error.Unknown;
    }
    var pFramesWritten: usize = 0;
    for (list.items) |buf| {
        const buffer = @as([*c]f32, @ptrCast(@alignCast(buf)));
        _ = ma.ma_encoder_write_pcm_frames(&encoder, buffer, buf.len / 2, &pFramesWritten);
        allocator.free(buf);
    }
}

pub fn loadAudioFile(alloc: std.mem.Allocator, inFileName: []const u8) ![]f32 {
    var decoder = std.mem.zeroes(ma.ma_decoder);
    var config = ma.ma_decoder_config_init(ma.ma_format_f32, 2, settings.sampleRate);
    var res = ma.ma_decoder_init_file(inFileName.ptr, &config, &decoder);
    defer _ = ma.ma_decoder_uninit(&decoder);
    std.debug.print("file openend: {d}/{d}\n", .{ decoder.outputChannels, decoder.outputSampleRate });
    if (res != ma.MA_SUCCESS) {
        std.debug.print("Could not load file {s}: {d}\n", .{ inFileName, res });
        return error.Unknown;
    }

    var avail: c_ulonglong = 0;
    res = ma.ma_decoder_get_available_frames(&decoder, &avail);
    if (res != ma.MA_SUCCESS) {
        std.debug.print("Could get available frames:{d}\n", .{r});
        return error.Unknown;
    }
    //std.debug.print("available frames:{d}\n", .{avail});

    var mybuffer: []f32 = undefined;
    mybuffer = try alloc.alloc(f32, avail * 2);
    var read: c_ulonglong = 0;
    res = ma.ma_decoder_read_pcm_frames(&decoder, mybuffer.ptr, avail, &read);
    if (res != ma.MA_SUCCESS) {
        std.debug.print("Could read pcm frames:{d}\n", .{res});
        return error.Unknown;
    }
    return mybuffer;
}

var l: []f32 = undefined;
var r: []f32 = undefined;
var l1: []f32 = undefined;
var r1: []f32 = undefined;
var mixBuffer: [][*c]f32 = undefined;
var intitialized = false;

pub fn audio_callback(mydevice: ?*ma.ma_device, out: ?*anyopaque, input: ?*const anyopaque, frame_count: ma.ma_uint32) callconv(.C) void {
    if (mydevice == null or out == null) {
        return;
    }

    //const allocator = std.heap.page_allocator;
    var outw = @as([*c]f32, @ptrCast(@alignCast(out)));
    const inw = @as([*c]f32, @constCast(@ptrCast(@alignCast(input))));

    // Allocate buffers
    if (!intitialized) {
        l = allocator.alloc(f32, frame_count) catch return;
        r = allocator.alloc(f32, frame_count) catch return;
        l1 = allocator.alloc(f32, frame_count) catch return;
        r1 = allocator.alloc(f32, frame_count) catch return;

        // Allocate mixBuffer (2 channels)
        mixBuffer = allocator.alloc([*c]f32, 2) catch {
            allocator.free(l);
            allocator.free(r);
            allocator.free(l1);
            allocator.free(r1);
            return;
        };
        intitialized = true;
    }

    mixBuffer[0] = @as([*c]f32, @ptrCast(@alignCast(l)));
    mixBuffer[1] = @as([*c]f32, @ptrCast(@alignCast(r)));

    //defer allocator.free(mixBuffer);
    //defer allocator.free(l);
    // defer allocator.free(r);
    // defer allocator.free(l1);
    // defer allocator.free(r1);

    // Premix loop
    for (0..frame_count) |i| {
        const temp = mix();
        l[i] = temp[0];
        r[i] = temp[1];
        l1[i] = temp[2];
        r1[i] = temp[3];
    }

    // Apply Faust DSP
    const cc2: c_int = @intCast(frame_count);
    const outm: [*c][*c]f32 = @ptrCast(@alignCast(mixBuffer));
    mfx.computemydsp(fx, cc2, outm, outm);

    // Allocate rb for recording
    const rlen: usize = @intCast(frame_count * 2);

    var rb: []f32 = undefined;
    if (recorder.recording) {
        rb = allocator.alloc(f32, rlen) catch return;
    }

    // Combine input and mix
    if (recorder.lineIn and input != null) {
        for (0..frame_count) |i| {
            l[i] += inw[i * 2];
            r[i] += inw[i * 2 + 1];
        }
    }

    // Output loop
    for (0..frame_count) |i| {
        outw[i * 2] = l[i];
        outw[i * 2 + 1] = r[i];

        outw[i * 2] += l1[i];
        outw[i * 2 + 1] += r1[i];

        if (recorder.recording) {
            rb[i * 2] = l[i];
            rb[i * 2 + 1] = r[i];

            rb[i * 2] += l1[i];
            rb[i * 2 + 1] += r1[i];
        }
    }

    // Send to recorder
    if (recorder.recording) {
        recorder.appendToRecord(rb);
    }
}

pub fn startAudio() !bool {
    var device = std.mem.zeroes(ma.ma_device);
    var deviceConfig = ma.ma_device_config_init(ma.ma_device_type_duplex);
    deviceConfig.playback.format = ma.ma_format_f32;
    deviceConfig.playback.channels = 2;
    deviceConfig.sampleRate = settings.sampleRate;
    deviceConfig.dataCallback = audio_callback;
    deviceConfig.pUserData = null;
    const rout = ma.ma_device_init(null, &deviceConfig, &device);
    if (rout != ma.MA_SUCCESS) {
        std.debug.print("Device init failed:{d}\n", .{rout});
        return error.Unknown;
    }
    //defer ma.ma_device_uninit(&device);

    r = ma.ma_device_start(&device);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could get available frames\n", .{});
        return error.Unknown;
    }
    //defer r = ma.ma_device_stop(&device);
    std.debug.print("Device internal channels:{d}\n", .{device.playback.internalChannels});
    std.debug.print("Device internal channels:{s}\n", .{device.playback.name});
    //Keep structs alive and suspend... we trust in being resumed
    //suspend startAudioFrame = @frame();
    return true;
}
