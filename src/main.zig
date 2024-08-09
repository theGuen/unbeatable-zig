const std = @import("std");
const assert = std.debug.assert;

const mah = @cImport(@cInclude("miniaudio.h"));
const ma = @import("miniaudio.zig");
const mn = @import("menu.zig");
const smplr = @import("sampler.zig");
const rcdr = @import("recorder.zig");
const seq = @import("sequencer.zig");
const ui = @import("ui.zig");
const settings = @import("settings.zig");

var sampler: smplr.Sampler = undefined;

// TODO: extract a mixer
fn mix() [2]f32 {
    var sample = [2]f32{ 0, 0 };
    for (&sampler.sounds) |*p| {
        const temp = p.next();
        sample[0] += temp[0];
        sample[1] += temp[1];
    }
    return sample;
}

//fn asyncMain() void {
//    var frame = async ma.startAudio();
//    // this would be the return value of ma.startAudio()
//    const success = await frame;
//    _ = success catch return {};
//}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = general_purpose_allocator.deinit();
    const alloc = general_purpose_allocator.allocator();

    sampler = smplr.initSampler(alloc);
    defer sampler.deinit();
    try smplr.loadDefaultSamplerConfig(alloc, &sampler);
    var recorder = rcdr.newRecorder(alloc);

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arenaAlloc = arena.allocator();
    const fxMenuItems = try ma.init(alloc, arenaAlloc, mix, &recorder);

    _ = seq.newSequencer(arenaAlloc, &sampler);
    seq.loadSequence(&seq.sequencer, alloc, @constCast("project1.asd")) catch return {};

    var menu: mn.Menu = try mn.initMenu(alloc, arenaAlloc, &sampler, &recorder, &seq.sequencer, fxMenuItems);
    defer menu.deinit();

    //--------------------------------------------------------------------------------------------------------------------------
    //_ = async asyncMain();
    //--------------------------------------------------------------------------------------------------------------------------
    var ctxConfig: mah.ma_context_config = mah.ma_context_config_init();
    var context: mah.ma_context = undefined;
    var pPlaybackInfos: [*c]mah.ma_device_info = undefined;
    var playbackCount: mah.ma_uint32 = 0;
    var pCaptureInfos: [*c]mah.ma_device_info = undefined;
    var captureCount: mah.ma_uint32 = 0;

    var backends = [4]mah.ma_backend{ mah.ma_backend_coreaudio, mah.ma_backend_jack, mah.ma_backend_alsa, mah.ma_backend_pulseaudio };
    const cba = @as([*c]c_uint, @constCast(&backends));
    if (mah.ma_context_init(cba, 4, &ctxConfig, &context) != mah.MA_SUCCESS) {
        std.debug.print("ERROR: ma_context_init failed", .{});
    }
    if (mah.ma_context_get_devices(&context, &pPlaybackInfos, &playbackCount, &pCaptureInfos, &captureCount) != mah.MA_SUCCESS) {
        std.debug.print("ERROR: ma_context_get_devices failed", .{});
    }
    std.debug.print("INFO: selected backend: {d}, {s}\n", .{ context.backend, mah.ma_get_backend_name(context.backend) });
    var deviceId: [*c]mah.ma_device_id = undefined;
    var deviceIdCapture: [*c]mah.ma_device_id = undefined;
    var deviceIdDefault: [*c]mah.ma_device_id = undefined;
    var deviceIdDefaultCapture: [*c]mah.ma_device_id = undefined;
    for (0..playbackCount) |x| {
        std.debug.print("INFO:\t> available playback device: {d}, {s}\n", .{ x, pPlaybackInfos[x].name });
    }
    for (0..captureCount) |x| {
        std.debug.print("INFO:\t> available capture device: {d}, {s}\n", .{ x, pCaptureInfos[x].name });
    }

    var found = false;
    for (0..playbackCount) |x| {
        if (context.backend == mah.ma_backend_coreaudio and std.mem.startsWith(u8, &pPlaybackInfos[x].name, settings.coreaudioDefaultDevice)) {
            deviceId = &pPlaybackInfos[x].id;
            found = true;
            std.debug.print("INFO: selected device : {d}, {s}\n\n", .{ x, pPlaybackInfos[x].name });
        }
        if (context.backend == mah.ma_backend_pulseaudio and std.mem.startsWith(u8, &pPlaybackInfos[x].name, settings.pulseDefaultDevice)) {
            deviceId = &pPlaybackInfos[x].id;
            found = true;
            std.debug.print("INFO: selected device : {d}, {s}\n\n", .{ x, pPlaybackInfos[x].name });
        }
        if (context.backend == mah.ma_backend_alsa and std.mem.startsWith(u8, &pPlaybackInfos[x].name, settings.alsaDefaultDevice)) {
            deviceId = &pPlaybackInfos[x].id;
            found = true;
            std.debug.print("INFO: selected device : {d}, {s}\n\n", .{ x, pPlaybackInfos[x].name });
        }
        if (pPlaybackInfos[x].isDefault == 1) {
            deviceIdDefault = &pPlaybackInfos[x].id;
            std.debug.print("INFO: default device : {d}, {s}\n", .{ x, pPlaybackInfos[x].name });
        }
    }
    if (!found) {
        std.debug.print("INFO:\t> using default playback\n", .{});
        deviceId = deviceIdDefault;
    }
    found = false;
    for (0..captureCount) |x| {
        if (context.backend == mah.ma_backend_coreaudio and std.mem.startsWith(u8, &pCaptureInfos[x].name, settings.coreaudioDefaultDevice)) {
            deviceIdCapture = &pCaptureInfos[x].id;
            found = true;
            std.debug.print("INFO: selected capture device : {d}, {s}\n\n", .{ x, pCaptureInfos[x].name });
        }
        if (context.backend == mah.ma_backend_pulse and std.mem.startsWith(u8, &pCaptureInfos[x].name, settings.pulseDefaultDevice)) {
            deviceIdDefaultCapture = &pCaptureInfos[x].id;
            found = true;
            std.debug.print("INFO: selected device : {d}, {s}\n\n", .{ x, pCaptureInfos[x].name });
        }
        if (context.backend == mah.ma_backend_alsa and std.mem.startsWith(u8, &pCaptureInfos[x].name, settings.alsaDefaultDevice)) {
            deviceIdDefaultCapture = &pCaptureInfos[x].id;
            found = true;
            std.debug.print("INFO: selected device : {d}, {s}\n\n", .{ x, pCaptureInfos[x].name });
        }
        if (pCaptureInfos[x].isDefault == 1) {
            deviceIdDefaultCapture = &pCaptureInfos[x].id;
            std.debug.print("INFO: default capture device : {d}, {s}\n", .{ x, pCaptureInfos[x].name });
        }
    }
    if (!found) {
        std.debug.print("INFO:\t> using default capture \n", .{});
        deviceIdCapture = deviceIdDefaultCapture;
    }

    var device = std.mem.zeroes(mah.ma_device);
    var deviceConfig = mah.ma_device_config_init(mah.ma_device_type_duplex);

    deviceConfig.playback.pDeviceID = @constCast(deviceId);
    deviceConfig.playback.format = mah.ma_format_f32;
    deviceConfig.playback.channels = 2;

    deviceConfig.capture.pDeviceID = @constCast(deviceIdCapture);
    deviceConfig.capture.format = mah.ma_format_f32;
    deviceConfig.capture.channels = 2;
    deviceConfig.capture.shareMode = mah.ma_share_mode_shared;

    deviceConfig.sampleRate = 44100;
    deviceConfig.dataCallback = ma.audio_callback;
    deviceConfig.pUserData = null;
    var r = mah.ma_device_init(&context, &deviceConfig, &device);
    if (r != mah.MA_SUCCESS) {
        std.debug.print("ERROR: Device init failed:{d}\n", .{r});
        return error.Unknown;
    }
    defer mah.ma_device_uninit(&device);

    r = mah.ma_device_start(&device);
    if (r != mah.MA_SUCCESS) {
        std.debug.print("ERROR: Could get available frames\n", .{});
        return error.Unknown;
    }
    defer r = mah.ma_device_stop(&device);

    std.debug.print("INFO: Playbak Device Sample rates:{d}\n", .{device.playback.internalSampleRate});
    std.debug.print("INFO: Playbak Device internal channels:{d}\n\n", .{device.playback.internalChannels});
    std.debug.print("INFO: Capture Device Sample rates:{d}\n", .{device.capture.internalSampleRate});
    std.debug.print("INFO: Capture Device internal channels:{d}\n\n", .{device.capture.internalChannels});
    //--------------------------------------------------------------------------------------------------------------------------
    //
    //loop forever
    _ = try ui.drawWindow(&sampler, &menu, &seq.sequencer);
    std.debug.print("INFO: saving Sampler\n", .{});
    try smplr.saveSamplerConfig(alloc, &sampler);
    std.debug.print("INFO: saving Sequence\n", .{});
    try seq.saveSequence(&seq.sequencer);

    //resume ma.startAudioFrame;

    const argv = [_][]const u8{ "/bin/sh", settings.script_path };
    std.debug.print("INFO: {s}\n", .{argv});
    const proc = try std.ChildProcess.exec(.{
        .allocator = alloc,
        .argv = &argv,
    });
    defer alloc.free(proc.stdout);
    defer alloc.free(proc.stderr);
}
