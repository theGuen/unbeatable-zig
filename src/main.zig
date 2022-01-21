const ray = @cImport(@cInclude("raylibwrapper.h"));
const sndFile = @import("sndFile.zig");
const sndio = @import("sndio.zig");
const ma = @import("miniaudio.zig");

const std = @import("std");
const math = @import("std").math;
const assert = std.debug.assert;
const process = std.process;

var exit = false;
fn shouldExit()bool{
    return exit;
}

var sampler:Sampler = undefined;

const Sampler = struct{
    alloc: std.mem.Allocator,
    selectedSound: usize,
    sounds: [16]Sound,
    fn load(self: *Sampler, sample: *[]f32)void{
        var sound:*Sound = &self.sounds[self.selectedSound];
        //seems whe have to free the pointer last....
        var b = sound.buffer;
        sound.buffer = sample.*;
        sound.posf = 0;
        sound.reversed = false;
        std.debug.print("Loaded: {d}\n", .{self.selectedSound});
        self.selectedSound += 1;
        if(b.len>0){
            self.alloc.free(b);
        }
    }
    fn play(self: *Sampler,soundIndex:usize)void{
        self.selectedSound = soundIndex;
        self.sounds[soundIndex].play();
    }
    fn reverseSound(self: *Sampler)void{
        self.sounds[self.selectedSound].reverse();
    }
    fn loopSound(self: *Sampler)void{
        self.sounds[self.selectedSound].looping= !self.sounds[self.selectedSound].looping;
    }

};
fn initSampler(alloc: std.mem.Allocator)Sampler{
    var this = Sampler{.alloc = alloc,.selectedSound=0,.sounds=undefined};
    for (this.sounds) |*s|{
        s.buffer = &[_]f32{}; 
        s.posf = 0;
        s.playing = false;
        s.looping = false;
        s.reversed = false;
        s.pitch = 1;
        s.semis = 0;
    }
    return this;
}

const Sound = struct{
    buffer: []f32,
    posf : f64,
    playing: bool,
    looping :bool,
    reversed: bool,
    pitch :f32,
    semis:i64,
    fn next(p:*Sound)f32{
        if (p.buffer.len >0 and p.playing){
            var pos = @floatToInt(i64,p.posf);
            const ende = @intToFloat(f64,p.buffer.len-1);
            if(p.posf > ende and !p.reversed){
                p.posf = p.posf-ende;
                pos = @floatToInt(i64,p.posf);
                if(!p.looping)p.playing=false;
            }else if (p.posf < 0.0 and p.reversed){
                p.posf = @intToFloat(f64,(p.buffer.len-1))-(0.0-p.posf);
                pos = @floatToInt(i64,p.posf);
                if(!p.looping)p.playing=false;
            }
            if (!p.reversed){
                p.posf +=  p.pitch;
            }else{
                p.posf -= p.pitch;
            }
            return p.buffer[@intCast(usize,pos)];
        }else{
            return 0;
        }
    }
    fn play(p:*Sound)void{
        p.playing = true;
    }
    fn stop(p:*Sound)void{
        p.playing = false;
        if (!p.reversed){
                p.posf = 0;
            }else{
                p.posf = @intToFloat(f64,p.buffer.len-1);
            }
    }
    fn reverse(p:*Sound)void{
        p.reversed = !p.reversed;
        if (!p.reversed){
                p.posf = 0;
            }else{
                p.posf = @intToFloat(f64,p.buffer.len-1);
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
                sampler.play(i);
                btn_colors[i]=ray.ORANGE;
            }
            if (ray.IsKeyReleased(k)){
                sampler.sounds[i].stop();
                btn_colors[i]=ray.GREEN;
            }
        }
        if (ray.IsKeyPressed(ray.KEY_P)){
                sampler.reverseSound();
        }
        if (ray.IsKeyPressed(ray.KEY_L)){
                sampler.loopSound();
        }
        
        for (buttons) |*b,i|{
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)){
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)){
                    sampler.play(i);
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)){
                    sampler.sounds[i].stop();
                    btn_colors[i]=ray.GREEN;
                }
            }
        }
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Press a button to playing a sound", 10, 10, 5, ray.BLACK);
        for (buttons) |*b,i|{
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
    }
    exit = true;
}

pub fn main() !void {
    sampler = initSampler(std.heap.page_allocator); 
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const alloc = arena.allocator();
    try loadCmdLineArgSamples(alloc);
    std.debug.print("Sampler: {s}\n", .{sampler});
    try ma.ma_create_lowpass(alloc);
    ma.mix = mix;
    ma.exit = shouldExit;
    const audioThread = try std.Thread.spawn(.{}, ma.ma_init_audio, .{});
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
        var b = try ma.ma_load_file(sndAloc,arg1);
        sampler.load(b);
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
            if(ma.ma_load_file(sndAloc,bla))|b|{
                sampler.load(b);
            }else |err|{
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        }
    }
}
