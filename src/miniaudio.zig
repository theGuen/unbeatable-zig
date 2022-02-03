const std = @import("std");
const ma = @cImport(@cInclude("miniaudio.h"));
const mfx = @cImport(@cInclude("multifx1.h"));
const ui = @import("UIGlue.zig");
pub var mix: fn () f32 = undefined;
pub var exit: fn () bool = undefined;
pub var allocator: std.mem.Allocator = undefined;

pub var fx:[*c]mfx.mydsp = undefined;
var list:std.ArrayList([]f32) = undefined;

pub fn initDSP()![]ui.IMenuItem{
    fx = mfx.newmydsp();
    mfx.initmydsp(fx,44100);

    var uiGlue = try ui.newUIGlue();
    var uiGlue_c = @ptrCast([*c]mfx.UIGlue,uiGlue);
    mfx.buildUserInterfacemydsp(fx,uiGlue_c);
    var iitems = try ui.MenuItemsFromUIGlue(uiGlue);   
    return iitems;
}

pub fn saveAudioFile(inFileName: []const u8,myBuffer:[]f32)!void{    
    var buffer = @ptrCast([*c]f32, @alignCast(@alignOf([]f32), myBuffer));
    var config = ma.ma_encoder_config_init(ma.ma_encoding_format_wav, ma.ma_format_f32, 2, 44100);
    var encoder = std.mem.zeroes(ma.ma_encoder);
    var r  = ma.ma_encoder_init_file(inFileName.ptr, &config, &encoder);
    defer ma.ma_encoder_uninit(&encoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not init encoder {s}: {d}\n",.{inFileName,r});
        return  error.Unknown;
    }
    var pFramesWritten:usize = 0;
    r =  ma.ma_encoder_write_pcm_frames(&encoder, buffer, myBuffer.len/2, &pFramesWritten);
}

pub fn saveRecordedFile(inFileName: []const u8,)!void{
    var config = ma.ma_encoder_config_init(ma.ma_encoding_format_wav, ma.ma_format_f32, 2, 44100);
    var encoder = std.mem.zeroes(ma.ma_encoder);
    var r  = ma.ma_encoder_init_file(inFileName.ptr, &config, &encoder);
    defer ma.ma_encoder_uninit(&encoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not init encoder {s}: {d}\n",.{inFileName,r});
        return  error.Unknown;
    }
    var pFramesWritten:usize = 0;
    for(list.items)|buf|{
        var buffer = @ptrCast([*c]f32, @alignCast(@alignOf([]f32), buf));
        _ = ma.ma_encoder_write_pcm_frames(&encoder, buffer, buf.len/2, &pFramesWritten);
        allocator.free(buf);
    }
}

pub fn loadAudioFile(alloc:std.mem.Allocator,inFileName: []const u8)!*[]f32{
    var decoder = std.mem.zeroes(ma.ma_decoder);
    var config = ma.ma_decoder_config_init(ma.ma_format_f32, 2, 44100);
    var r = ma.ma_decoder_init_file(inFileName.ptr, &config, &decoder);
    defer _ = ma.ma_decoder_uninit(&decoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not load file {s}: {d}\n",.{inFileName,r});
        return  error.Unknown;
    }
    std.debug.print("file openend: {d}/{d}\n", .{decoder.outputChannels,decoder.outputSampleRate});
    var avail:c_ulonglong=0;
    r = ma.ma_decoder_get_available_frames(&decoder,&avail);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could get available frames:{d}\n",.{r});
        return  error.Unknown;
    }
    std.debug.print("available frames:{d}\n", .{avail});

    var mybuffer: []f32 = undefined;
    mybuffer = try alloc.alloc(f32, avail*2);
    var read:c_ulonglong=0;
    r = ma.ma_decoder_read_pcm_frames(&decoder, mybuffer.ptr,avail ,&read);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could read pcm frames:{d}\n",.{r});
        return  error.Unknown;
    }
    return &mybuffer;
}

fn audio_callback(device: ?*ma.ma_device, out: ?*anyopaque, input: ?*const anyopaque, frame_count: ma.ma_uint32) callconv(.C) void {
    _ = input;
    _ = device;
    var outw = @ptrCast([*c]f32, @alignCast(@alignOf([]f32), out));
    for (outw[0..frame_count*2]) |*b| b.* = mix();

    var cc:c_int = @intCast(c_int,frame_count*2);
    mfx.computemydsp(fx, cc, outw, outw);

    const l = @intCast(usize,frame_count*2);
    var rb = allocator.alloc(f32,l) catch return {};
    for (outw[0..frame_count*2])|_,i| rb[i] = outw[i];
    list.append(rb)catch return {};
}

pub fn startAudio()!void{
    list = std.ArrayList([]f32).init(allocator);
    defer list.deinit();
    var device = std.mem.zeroes(ma.ma_device);
    var deviceConfig = ma.ma_device_config_init(ma.ma_device_type_playback);
    deviceConfig.playback.format   = ma.ma_format_f32;
    deviceConfig.playback.channels = 2;
    deviceConfig.sampleRate        = 44100;
    deviceConfig.dataCallback      = audio_callback;
    deviceConfig.pUserData         = null;
    var r = ma.ma_device_init(null, &deviceConfig, &device);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Device init failed:{d}\n",.{r});
        return  error.Unknown;
    }
    defer ma.ma_device_uninit(&device);
    
    r = ma.ma_device_start(&device);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could get available frames\n",.{});
        return  error.Unknown;
    }
    defer r = ma.ma_device_stop(&device);
    std.debug.print("Device internal channels:{d}\n",.{device.playback.internalChannels});
    while (!exit()){}
    
    try saveRecordedFile("record.wav");
}