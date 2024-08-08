const std = @import("std");
const ma = @cImport(@cInclude("miniaudio.h"));
const mfx = @cImport(@cInclude("multifx22.h"));
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");

const mixerFunction = *const fn () [2]f32;
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
    mfx.initmydsp(fx, 44100);

    var uiGlue = try ui.newUIGlue();
    var uiGlue_c = @as([*c]mfx.UIGlue, @ptrCast(uiGlue));
    mfx.buildUserInterfacemydsp(fx, uiGlue_c);
    var items = try ui.MenuItemsFromUIGlue(aMenuAllocator, uiGlue);
    return items;
}

pub fn saveAudioFile(inFileName: []const u8, myBuffer: []f32) !void {
    var buffer = @as([*c]f32, @ptrCast(@alignCast(myBuffer)));
    var config = ma.ma_encoder_config_init(ma.ma_encoding_format_wav, ma.ma_format_f32, 2, 44100);
    var encoder = std.mem.zeroes(ma.ma_encoder);
    var r = ma.ma_encoder_init_file(inFileName.ptr, &config, &encoder);
    defer ma.ma_encoder_uninit(&encoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not init encoder {s}: {d}\n", .{ inFileName, r });
        return error.Unknown;
    }
    //var pFramesWritten: c_ulonglong = 0;
    var pFramesWritten: usize = 0;
    r = ma.ma_encoder_write_pcm_frames(&encoder, buffer, myBuffer.len / 2, &pFramesWritten);
}

pub fn saveRecordedFile(inFileName: []const u8, list: std.ArrayList([]f32)) !void {
    var config = ma.ma_encoder_config_init(ma.ma_encoding_format_wav, ma.ma_format_f32, 2, 44100);
    var encoder = std.mem.zeroes(ma.ma_encoder);
    var r = ma.ma_encoder_init_file(inFileName.ptr, &config, &encoder);
    defer ma.ma_encoder_uninit(&encoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not init encoder {s}: {d}\n", .{ inFileName, r });
        return error.Unknown;
    }
    var pFramesWritten: usize = 0;
    for (list.items) |buf| {
        var buffer = @as([*c]f32, @ptrCast(@alignCast(buf)));
        _ = ma.ma_encoder_write_pcm_frames(&encoder, buffer, buf.len / 2, &pFramesWritten);
        allocator.free(buf);
    }
}

pub fn loadAudioFile(alloc: std.mem.Allocator, inFileName: []const u8) ![]f32 {
    var decoder = std.mem.zeroes(ma.ma_decoder);
    var config = ma.ma_decoder_config_init(ma.ma_format_f32, 2, 44100);
    var r = ma.ma_decoder_init_file(inFileName.ptr, &config, &decoder);
    defer _ = ma.ma_decoder_uninit(&decoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not load file {s}: {d}\n", .{ inFileName, r });
        return error.Unknown;
    }
    //std.debug.print("file openend: {d}/{d}\n", .{ decoder.outputChannels, decoder.outputSampleRate });
    var avail: c_ulonglong = 0;
    r = ma.ma_decoder_get_available_frames(&decoder, &avail);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could get available frames:{d}\n", .{r});
        return error.Unknown;
    }
    //std.debug.print("available frames:{d}\n", .{avail});

    var mybuffer: []f32 = undefined;
    mybuffer = try alloc.alloc(f32, avail * 2);
    var read: c_ulonglong = 0;
    r = ma.ma_decoder_read_pcm_frames(&decoder, mybuffer.ptr, avail, &read);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could read pcm frames:{d}\n", .{r});
        return error.Unknown;
    }
    return mybuffer;
}

pub fn audio_callback(mydevice: ?*ma.ma_device, out: ?*anyopaque, input: ?*const anyopaque, frame_count: ma.ma_uint32) callconv(.C) void {
    //_ = input;
    _ = mydevice;
    var outw = @as([*c]f32, @ptrCast(@alignCast(out)));
    const inw = @as([*c]f32, @constCast(@ptrCast(@alignCast(input))));

    //Should we reuse the samebuffer?
    var mixBuffer = allocator.alloc([*c]f32, 2) catch return {};
    var l = allocator.alloc(f32, frame_count) catch return {};
    var r = allocator.alloc(f32, frame_count) catch return {};
    mixBuffer[0] = @as([*c]f32, @ptrCast(@alignCast(l)));
    mixBuffer[1] = @as([*c]f32, @ptrCast(@alignCast(r)));

    defer allocator.free(l);
    defer allocator.free(r);
    defer allocator.free(mixBuffer);

    //Premix loop
    {
        var i: usize = 0;
        while (i < frame_count) {
            const temp = mix();
            l[i] = temp[0];
            r[i] = temp[1];
            i += 1;
        }
    }

    //apply faust dsp
    var cc2: c_int = @intCast(frame_count);
    var outm: [*c][*c]f32 = @ptrCast(@alignCast(mixBuffer));
    mfx.computemydsp(fx, cc2, outm, outm);

    const rlen: usize = @intCast(frame_count * 2);
    var rb = allocator.alloc(f32, rlen) catch return {};
    //The recorder has to free this
    if (recorder.lineIn) {
        {
            var i: usize = 0;
            while (i < frame_count) {
                l[i] += inw[i * 2];
                r[i] += inw[i * 2 + 1];
                i += 1;
            }
        }
    }
    // Output loop
    {
        var i: usize = 0;
        while (i < frame_count) {
            outw[i * 2] = l[i];
            outw[i * 2 + 1] = r[i];
            rb[i * 2] = l[i];
            rb[i * 2 + 1] = r[i];
            i += 1;
        }
    }
    if (recorder.recording) {
        //send to recorder
        recorder.appendToRecord(rb);
    }
}

pub fn startAudio() !bool {
    var device = std.mem.zeroes(ma.ma_device);
    var deviceConfig = ma.ma_device_config_init(ma.ma_device_type_duplex);
    deviceConfig.playback.format = ma.ma_format_f32;
    deviceConfig.playback.channels = 2;
    deviceConfig.sampleRate = 44100;
    deviceConfig.dataCallback = audio_callback;
    deviceConfig.pUserData = null;
    var r = ma.ma_device_init(null, &deviceConfig, &device);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Device init failed:{d}\n", .{r});
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
