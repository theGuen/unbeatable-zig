const std = @import("std");
const ma = @cImport(@cInclude("miniaudio.h"));
pub var mix: fn () f32 = undefined;
pub var exit: fn () bool = undefined;

var lpf:ma.ma_lpf = undefined;
var lpfConf:ma.ma_lpf_config = undefined;
var lpfBuf:[]u8 = undefined;

pub fn lpfFreq()void{
    lpfConf.cutoffFrequency +=100;
    _= ma.ma_lpf_reinit(&lpfConf, &lpf);
}

pub fn destroyLowPass(alloc:std.mem.Allocator)void{
    alloc.free(lpfBuf);
}

pub fn createLowpass(alloc:std.mem.Allocator)!void{       
    lpf = std.mem.zeroes(ma.ma_lpf);
    var heapSizeInBytes:usize = 1;
    lpfConf = ma.ma_lpf_config_init(ma.ma_format_f32, 2, 44100, 1024, 4);
    var r = ma.ma_lpf_get_heap_size(&lpfConf, &heapSizeInBytes);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("ma_lpf_get_heap_size failed:{d}\n",.{r});
    }
    
    std.debug.print("HERE\n",.{});
    lpfBuf = try alloc.alloc(u8, heapSizeInBytes);
    var bufPtr = @ptrCast(*anyopaque, lpfBuf);  
    r = ma.ma_lpf_init_preallocated(&lpfConf, bufPtr,&lpf);
    std.debug.print("HERE\n",.{});
    if (r != ma.MA_SUCCESS) {
        std.debug.print("ma_lpf_init failed:{d}\n",.{r});
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

fn ma_add_lowpass(out: [*c]f32,in: [*c]f32,frame_count: ma.ma_uint32)void{

    var r = ma.ma_lpf_process_pcm_frames(&lpf, out, in, frame_count); 
    if (r != ma.MA_SUCCESS) {
        std.debug.print("ma_lpf_process_pcm_frames failed:{d}\n",.{r});
    }

}

fn audio_callback(device: ?*ma.ma_device, out: ?*anyopaque, input: ?*const anyopaque, frame_count: ma.ma_uint32) callconv(.C) void {
    _ = input;
    _ = device;
    var outw = @ptrCast([*c]f32, @alignCast(@alignOf([]f32), out));
    for (outw[0..frame_count*2]) |*b| b.* = mix();
    ma_add_lowpass(outw,outw,frame_count);
}

pub fn startAudio()!void{
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
}