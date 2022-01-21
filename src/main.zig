const ma = @cImport(@cInclude("miniaudio.h"));
const ray = @cImport(@cInclude("raylibwrapper.h"));
const sndFile = @import("sndFile.zig");
const sndio = @import("sndio.zig");

const std = @import("std");
const math = @import("std").math;
const assert = std.debug.assert;
const process = std.process;

var exit = false;
fn shouldExit()bool{
    return exit;
}

var lpf:ma.ma_lpf = undefined;
var lpfConf:ma.ma_lpf_config = undefined;
var sampler:Sampler = undefined;

const Sampler = struct{
    selectedSound: usize,
    sounds: [16]Sound,
    fn load(self: *Sampler,aloc: std.mem.Allocator, sample: *[]f32)void{
        var sound:*Sound = &self.sounds[self.selectedSound];
        //TODO: Why do i need the sndPtr...
        if (sound.loaded){
            var sndPtr = &self.*.sounds[self.selectedSound];
            sndPtr.loaded = false;
            sound.aloc.free(sound.buffer);
        }
        sound.buffer = sample.*;
        sound.loaded = true;
        sound.play = false;
        sound.reverse = true;   
        sound.posf = 1;
        sound.loop = false;    
        sound.pitch = 1;
        sound.aloc = aloc;
        std.debug.print("Loaded: {d}\n", .{self.selectedSound});
        self.selectedSound += 1;
    }
    fn reverseSound(self: *Sampler)void{
        self.sounds[self.selectedSound].reverseIt();
    }
};

const Sound = struct{
    buffer: []f32,
    posf : f64,
    play: bool,
    loop :bool,
    loaded:bool,
    reverse: bool,
    pitch :f32,
    semis:i64,
    aloc:std.mem.Allocator,
    fn next(p:*Sound)f32{
        if (p.loaded and p.play){
            var pos = @floatToInt(usize,p.posf);
            const ende = @intToFloat(f32,p.buffer.len-1);
            if(p.posf > ende and !p.reverse){
                p.posf = p.posf-ende;
                pos = @floatToInt(usize,p.posf);
                if(!p.loop)p.play=false;
            }else if (p.posf <= 0.0 and p.reverse){
                p.posf = @intToFloat(f32,(p.buffer.len-1))-(0.0-p.posf);
                pos = @floatToInt(usize,p.posf);
                if(!p.loop)p.play=false;
            }
            if (!p.reverse){
                p.posf +=  p.pitch;
            }else{
                p.posf -= p.pitch;
            }
            return p.buffer[pos];
        }else{
            return 0;
        }
    }
    fn playIt(p:*Sound)void{
        p.play = true;
    }
    fn stopIt(p:*Sound)void{
        p.play = false;
        if (!p.reverse){
                p.posf = 0;
            }else{
                p.posf = @intToFloat(f32,p.buffer.len-1);
            }
    }
    fn reverseIt(p:*Sound)void{
        p.reverse = !p.reverse;
        if (!p.reverse){
                p.posf = 0;
            }else{
                p.posf = @intToFloat(f32,p.buffer.len-1);
            }
    }
};

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

fn mix()f32{   
    var sample:f32 = 0.0;
    for (sampler.sounds) |*p|{
        sample += p.next();  
    }
    if (sample > 1){
        sample = 1;
    }else if (sample < -1){
        sample = -1;
    }
    return sample*0.8;
}

fn change_lpf_freq()void{
    lpfConf.cutoffFrequency +=100;
    _= ma.ma_lpf_reinit(&lpfConf, &lpf);
}

fn ma_create_lowpass(alloc:std.mem.Allocator)!void{       
    lpf = std.mem.zeroes(ma.ma_lpf);
    var heapSizeInBytes:usize = 1;
    lpfConf = ma.ma_lpf_config_init(ma.ma_format_f32, 2, 44100, 1024, 4);
    var r = ma.ma_lpf_get_heap_size(&lpfConf, &heapSizeInBytes);
    if (r != ma.MA_SUCCESS) {
        std.debug.print("ma_lpf_get_heap_size failed:{d}\n",.{r});
    }
    
    std.debug.print("HERE\n",.{});
    var buf = try alloc.alloc([]u8, heapSizeInBytes);
    var bufPtr = @ptrCast(*anyopaque, buf);  
    r = ma.ma_lpf_init_preallocated(&lpfConf, bufPtr,&lpf);
    std.debug.print("HERE\n",.{});
    if (r != ma.MA_SUCCESS) {
        std.debug.print("ma_lpf_init failed:{d}\n",.{r});
    }
    
}

fn ma_add_lowpass(out: [*c]f32,in: [*c]f32,frame_count: ma.ma_uint32)void{

    var r = ma.ma_lpf_process_pcm_frames(&lpf, out, in, frame_count); 
    if (r != ma.MA_SUCCESS) {
        std.debug.print("ma_lpf_process_pcm_frames failed:{d}\n",.{r});
    }

}

fn ma_audio_callback(device: ?*ma.ma_device, out: ?*anyopaque, input: ?*const anyopaque, frame_count: ma.ma_uint32) callconv(.C) void {
    _ = input;
    _ = device;
    var outw = @ptrCast([*c]f32, @alignCast(@alignOf([]f32), out));
    for (outw[0..frame_count*2]) |*b| b.* = mix();
    ma_add_lowpass(outw,outw,frame_count);
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

fn ma_load_file(alloc:std.mem.Allocator,inFileName: []const u8)!*[]f32{
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
    if(mybuffer[10]== -1*math.nan(f32)){
        mybuffer[10]=0;
    }
    return &mybuffer;
}

// TODO:This loop takes 33M in memory???
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
    const keys = [_]c_int{ray.KEY_ONE,ray.KEY_TWO,ray.KEY_THREE,ray.KEY_FOUR,ray.KEY_Q,ray.KEY_W,ray.KEY_E,ray.KEY_R,ray.KEY_A,ray.KEY_S,ray.KEY_D,ray.KEY_F,ray.KEY_Z,ray.KEY_X,ray.KEY_C,ray.KEY_V};

    while (!ray.WindowShouldClose()) {
        var mousePosition = ray.GetMousePosition();

        for (keys)|k,i|{
            if (ray.IsKeyPressed(k)){
                sampler.sounds[i].playIt();
                sampler.selectedSound = i;
                btn_colors[i]=ray.ORANGE;
            }
            if (ray.IsKeyReleased(k)){
                sampler.sounds[i].stopIt();
                btn_colors[i]=ray.GREEN;
            }
        }
        if (ray.IsKeyPressed(ray.KEY_P)){
                sampler.reverseSound();
        }
        
        
        for (buttons) |*b,i|{
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)){
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)){
                    sampler.sounds[i].playIt();
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)){
                    sampler.sounds[i].stopIt();
                    btn_colors[i]=ray.GREEN;
                }
            }
        }
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Press a button to play a sound", 10, 10, 5, ray.BLACK);
        for (buttons) |*b,i|{
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
    }
    exit = true;
}

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    try loadCmdLineArgSamples(alloc);
    std.debug.print("Sampler: {s}\n", .{sampler});
    try ma_create_lowpass(alloc);
    const audioThread = try std.Thread.spawn(.{}, ma_init_audio, .{});
    //sndio.mix = mix;
    //sndio.exit = shouldExit;
    //const audioThread = try std.Thread.spawn(.{},sndio.start_audio, .{});
    
    //TODO: just for now.. ui can't load samples
    _ = try std.Thread.spawn(.{}, userInput, .{});
    //Loop forever
    _ = drawWindow();
    audioThread.join();
}

fn loadCmdLineArgSamples(alloc:std.mem.Allocator)!void{
    var args = process.args();
    // skip my own exe name
    _ = args.skip();
    
    while (true){
        const arg1 = (try args.next(alloc) orelse {
            break;
        });   
        var sndAloc = std.heap.page_allocator;
        var b = try ma_load_file(sndAloc,arg1);
        sampler.load(sndAloc,b);
    }
}

fn userInput()!void{ 
    while (true){
        var buf: [1000]u8 = undefined;
        // We need a 0 terminated string... how unpleasant
        for (buf) |_,ii| buf[ii] = 0;
        const stdin = std.io.getStdIn().reader();
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            var sndAloc = std.heap.page_allocator;
            const bla:[]u8 = user_input;
            if(ma_load_file(sndAloc,bla))|b|{
                sampler.load(sndAloc,b);
            }else |err|{
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        }
    }
}
