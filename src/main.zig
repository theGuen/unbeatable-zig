const c = @cImport(@cInclude("soundio/soundio.h"));
const sf = @cImport(@cInclude("sndfile.h"));
const ma = @cImport(@cInclude("miniaudio.h"));
const ray = @cImport(@cInclude("raylibwrapper.h"));

const std = @import("std");
const math = @import("std").math;
const assert = std.debug.assert;
const process = std.process;

var sounds: [16]Sound = undefined;
var exit = false;
fn sio_err(err: c_int) !void {
    switch (err) {
         0 => {},
        else => return error.Unknown,
    }
}
const Info = extern struct {
    frames: i64,
    samplerate: c_int,
    channels: c_int,
    format: c_int,
    sections: c_int,
    seekable: c_int,
};

const Sound = struct{
    buffer: []f32,
    posf : f64,
    play: bool,
    loaded:bool,
    reverse: bool,
    pitch :f32,
    aloc:std.mem.Allocator,
};

fn unloadSound(index: usize)void{
    sounds[index].loaded = false;
    sounds[index].aloc.free(sounds[index].buffer);
    sounds[index].buffer = &[_]f32{};

}

fn loadSound(aloc: std.mem.Allocator, index: usize, sample: *[]f32)void{
    sounds[index].buffer = sample.*;
    sounds[index].play = false;
    sounds[index].reverse = false;
    sounds[index].pitch = 1;
    sounds[index].loaded = true;
    sounds[index].aloc = aloc;
    sounds[index].pitch = pitchSemis(-2);
}

fn mix()f32{   
    var sample:f32 = 0.0;
    for (sounds) |p,i|{
        if (p.loaded and p.play){
            var pos = @floatToInt(usize,p.posf);
            const ende = @intToFloat(f32,p.buffer.len-1);
            if(p.posf > ende and !p.reverse){
                sounds[i].posf = p.posf-ende;
                pos = @floatToInt(usize,sounds[i].posf);
            }else if (p.posf <= 0.0 and p.reverse){
                sounds[i].posf = @intToFloat(f32,(p.buffer.len-1))-(0.0-p.posf);
                pos = @floatToInt(usize,sounds[i].posf);
            }

            sample += p.buffer[pos];
            
            if (!p.reverse){
                sounds[i].posf +=  p.pitch;
            }else{
                sounds[i].posf -= p.pitch;
            }
        }
    }
    if (sample > 1){
        sample = 1;
    }else if (sample < -1){
        sample = -1;
    }
    return sample*0.8;
}

fn pitchSemis(pitch: i64)f32{
    const pitchstep = 1.05946;
    const abs:u64 = math.absCast(pitch);
    var oct = abs / 12;
    const semi = abs - (12*oct);
    oct += 1;
    var p:f32 = 0.0;
    if(pitch < 0){
        p = math.pow(f32,pitchstep, @intToFloat(f32,(12 - semi)));
        p = p * 1 / math.pow(f32,2, @intToFloat(f32,oct));       
    } else if (pitch > 0 and pitch < 12) {
        p = math.pow(f32,pitchstep, @intToFloat(f32,semi));
        p = p * @intToFloat(f32,oct);
    } else if (pitch == 12) {
        p = 2;
    } else if (pitch > 12) {
        p = 2.1;
    } else {
        p = 1;
    }
    return p;
}

fn sndio_audio_callback(maybe_outstream: ?[*]c.SoundIoOutStream, frame_count_min: c_int, frame_count_max: c_int) callconv(.C) void {
    _ = frame_count_min;
    const outstream = @ptrCast(*c.SoundIoOutStream, maybe_outstream);
    const layout = &outstream.layout;
    var frames_left = frame_count_max;

    while (frames_left > 0) {
        var frame_count = frames_left;
        var areas: [*]c.SoundIoChannelArea = undefined;
        sio_err(c.soundio_outstream_begin_write(maybe_outstream, @ptrCast([*]?[*]c.SoundIoChannelArea, &areas), &frame_count)) catch |err| std.debug.panic("write failed: {s}", .{@errorName(err)});
        if (frame_count == 0) break;
        var frame: c_int = 0;
        while (frame < frame_count) : (frame += 1) {
            {
                var channel: usize = 0;
                while (channel < @intCast(usize, layout.channel_count)) : (channel += 1) {
                    const sample = mix();

                    const channel_ptr = areas[channel].ptr;
                    const sample_ptr = &channel_ptr[@intCast(usize, areas[channel].step * frame)];
                    @ptrCast(*f32, @alignCast(@alignOf(f32), sample_ptr)).* = sample;
                }
            }
        }
        sio_err(c.soundio_outstream_end_write(maybe_outstream)) catch |err| std.debug.panic("end write failed: {s}", .{@errorName(err)});
        frames_left -= frame_count;
    }
}
fn sndio_init_audio()!void{
    const soundio = c.soundio_create();
    defer c.soundio_destroy(soundio);
    try sio_err(c.soundio_connect(soundio));
    c.soundio_flush_events(soundio);

    const default_output_index = c.soundio_default_output_device_index(soundio);
    if (default_output_index < 0) return error.NoOutputDeviceFound;

    const device = c.soundio_get_output_device(soundio, default_output_index) orelse return error.OutOfMemory;
    defer c.soundio_device_unref(device);

    std.debug.print("Output device: {s}\n", .{device.*.name});
    const outstream = c.soundio_outstream_create(device) orelse return error.OutOfMemory;
    outstream.*.sample_rate = 44100;
    defer c.soundio_outstream_destroy(outstream);
    outstream.*.format = c.SoundIoFormatFloat32NE;
    outstream.*.write_callback = sndio_audio_callback;
    std.debug.print("Output Samplerate: {d}hz\n", .{outstream.*.sample_rate});

    try sio_err(c.soundio_outstream_open(outstream));
    try sio_err(c.soundio_outstream_start(outstream));
    while (!exit) c.soundio_wait_events(soundio);
}

fn ma_audio_callback(device: ?*ma.ma_device, out: ?*anyopaque, input: ?*const anyopaque, frame_count: ma.ma_uint32) callconv(.C) void {
    _ = input;
    _ = device;
    var outw = @ptrCast([*c]f32, @alignCast(@alignOf([]f32), out));
    for (outw[0..frame_count*2]) |*b| b.* = mix();
}
fn ma_init_audio()!void{
    var device = std.mem.zeroes(ma.ma_device);
    var deviceConfig = ma.ma_device_config_init(ma.ma_device_type_playback);
    deviceConfig.playback.format   = ma.ma_format_f32;
    deviceConfig.playback.channels = 2;
    deviceConfig.sampleRate        = 44100;
    deviceConfig.dataCallback      = ma_audio_callback;
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
    while (!exit){}
}

fn ma_load_file(aloc:std.mem.Allocator,inFileName: []const u8)!*[]f32{
    var decoder = std.mem.zeroes(ma.ma_decoder);
    var config = ma.ma_decoder_config_init(ma.ma_format_f32, 2, 44100);
    var r = ma.ma_decoder_init_file(inFileName.ptr, &config, &decoder);
    defer _ = ma.ma_decoder_uninit(&decoder);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could not load file\n",.{});
        return  error.Unknown;
    }
    std.debug.print("file openend: {d}/{d}\n", .{decoder.outputChannels,decoder.outputSampleRate});
    var avail:c_ulonglong=0;
    r = ma.ma_decoder_get_available_frames(&decoder,&avail);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could avail frames:{d}\n",.{r});
        return  error.Unknown;
    }
    std.debug.print("avail frames: {d}\n", .{avail});

    var mybuffer: []f32 = undefined;
    mybuffer = try aloc.alloc(f32, avail*2);
    var read:c_ulonglong=0;
    r = ma.ma_decoder_read_pcm_frames(&decoder, mybuffer.ptr,avail ,&read);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("Could read frames:{d}\n",.{r});
        return  error.Unknown;
    }
    if(mybuffer[10]== -1*math.nan(f32)){
        mybuffer[10]=0;
    }
    std.debug.print("read frames: {d}\n", .{mybuffer[10]});
    return &mybuffer;
}

fn snd_load_file(allocator:std.mem.Allocator,inFileName: []const u8) !*[]f32{
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

fn drawWindow() void {
    const screenWidth = 450;
    const screenHeight = 500;

    ray.InitWindow(screenWidth, screenHeight, "Unbeatable - ZIG");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    var buttons : [16]ray.Rectangle= undefined;
    for (buttons) |*b,i|{
        const ix = @intToFloat(f32,10 + (i%4)*10+(i%4)*100);
        const iy = @intToFloat(f32,50 + (i/4)*10+(i/4)*100);
        b.* = ray.Rectangle{ .x=ix, .y=iy, .width=100, .height=100 };
    }
    var btn_colors : [16]ray.Color= undefined;
    for (btn_colors) |*b|{
        b.* = ray.GREEN;
    }
    const keys = [_]c_int{ray.KEY_ONE,ray.KEY_TWO,ray.KEY_THREE,ray.KEY_FOUR,ray.KEY_Q,ray.KEY_W,ray.KEY_E,ray.KEY_R,ray.KEY_A,ray.KEY_S,ray.KEY_D,ray.KEY_F,ray.KEY_Y,ray.KEY_X,ray.KEY_C,ray.KEY_V};

    while (!ray.WindowShouldClose()) {
        var mousePosition = ray.GetMousePosition();

        for (keys)|k,i|{
            if (ray.IsKeyPressed(k)){
                sounds[i].play = true;
                btn_colors[i]=ray.ORANGE;
            }
            if (ray.IsKeyReleased(k)){
                sounds[i].play = false;
                sounds[i].posf =0;
                btn_colors[i]=ray.GREEN;
            }
        }
        
        for (buttons) |*b,i|{
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)){
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)){
                    sounds[i].play = true;
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)){
                    sounds[i].play = false;
                    sounds[i].posf =0;
                    btn_colors[i]=ray.GREEN;
                }
            }
        }
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Press a button to play a sound", 10, 10, 20, ray.LIGHTGRAY);
        for (buttons) |*b,i|{
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
    }
    exit = true;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    var args = process.args();
    //std.debug.print("Number of args: {d} \n",.{args.len});
    // skip my own exe name
    _ = args.skip();

    const alloc = arena.allocator();
    const arg1 = (try args.next(alloc) orelse {
        std.debug.print("Expected first argument to be a wav file \n",.{});
        return error.InvalidArgs;
    });
    var inFileName2 : []const u8 = "testdata/drum.wav";

    const audioThread = try std.Thread.spawn(.{}, ma_init_audio, .{});
    
    var sndAloc = std.heap.page_allocator;
    var b = try ma_load_file(sndAloc,arg1);
    loadSound(sndAloc,0,b); 
    //unloadSound(0);

    sndAloc = std.heap.page_allocator;
    b = try ma_load_file(sndAloc,inFileName2);
    loadSound(sndAloc,1,b);

    //Loop forever
    _ = drawWindow();
    audioThread.join();
}
