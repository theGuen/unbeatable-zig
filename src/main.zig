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
        defer self.alloc.free(b);
        
        sound.buffer = sample.*;
        sound.posf = 0;
        sound.reversed = false;
        std.debug.print("Loaded: {d}\n", .{self.selectedSound});
        self.selectedSound += 1;
        
    }
    fn freeAll(self: *Sampler)void{
        for (self.sounds) |*s|{
            var b = s.buffer;
            defer self.alloc.free(b);

            s.playing =false;
            s.posf = 0;
            s.buffer = &[_]f32{};
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

const SamplerW = struct{
    sounds: [16]SoundW
};
const SoundW = struct{
    name : []u8,
    looping :bool,
    reversed: bool,
    pitch :f32,
    semis:i64
};

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
// TODO: Pass the sampler
fn drawWindow(samplers:*Sampler) !void {
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
    var textBox = ray.Rectangle{ .x=230, .y=5, .width=210, .height=25 };
    //TODO: use another allocator
    var dta = std.heap.page_allocator.alloc(u8, 256)catch |err| std.debug.panic("write failed: {s}", .{@errorName(err)});
    defer std.heap.page_allocator.free(dta);
    dta[0]=0;
    for (dta[0..255]) |*b| b.* = 0;
    var dt = @ptrCast([*c]u8,dta);
    var letterCount:usize = 0;
    var onText = false;

    while (!ray.WindowShouldClose()) {
        var mousePosition = ray.GetMousePosition();
        for (buttons) |*b,i|{
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)){
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)){
                    samplers.play(i);
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)){
                    samplers.sounds[i].stop();
                    btn_colors[i]=ray.GREEN;
                }
            }
        }
        if (ray.WrapCheckCollisionPointRec(&mousePosition, &textBox)){
            onText = true;
            var key = ray.GetCharPressed();
            while (key > 0){
                if ((key >= 32) and(key <= 125) and (letterCount < 255)){
                    dt[letterCount] = @intCast(u8,key);
                    dt[letterCount+1] = 0; // Add null terminator at the end of the string.
                    letterCount+=1;
                }
                key = ray.GetCharPressed();  // Check next character in the queue
            }

            if (ray.IsKeyPressed(ray.KEY_BACKSPACE)){
                letterCount-=1;
                if (letterCount < 0) letterCount = 0;
                dt[letterCount] = 0;
            }
            if (ray.IsKeyPressed(ray.KEY_ENTER)){
                if (dta[0] != 0){
                    if(ma.loadAudioFile(sampler.alloc,dta))|b|{
                        samplers.load(b);
                        for (dta[0..255]) |*x| x.* = 0;
                        letterCount = 0;
                    }else |err|{
                        std.debug.print("ERROR: {s}\n", .{@errorName(err)});
                    }
                }
            }
        }else{
            onText = false;
            for (keys)|k,i|{
                if (ray.IsKeyPressed(k)){
                    samplers.play(i);
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsKeyReleased(k)){
                    samplers.sounds[i].stop();
                    btn_colors[i]=ray.GREEN;
                }
            }
            if (ray.IsKeyPressed(ray.KEY_P)){
                samplers.reverseSound();
            }
            if (ray.IsKeyPressed(ray.KEY_L)){
                samplers.loopSound();
            }
        }
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Enter a sample name to load ->", 10, 10, 8, ray.BLACK);
        ray.DrawText("Press a button to playing a sound", 10, 20, 8, ray.BLACK);
        
        ray.WrapDrawRectangleRec(&textBox, ray.GRAY);
        if (onText){
             ray.DrawRectangleLines(@floatToInt(c_int,textBox.x), @floatToInt(c_int,textBox.y), @floatToInt(c_int,textBox.width), @floatToInt(c_int,textBox.height), ray.RED);
             ray.DrawText("_", @floatToInt(c_int,textBox.x) + 8 + ray.MeasureText(dt, 15), @floatToInt(c_int,textBox.y) + 10, 15, ray.MAROON);
        }else{
             ray.DrawRectangleLines(@floatToInt(c_int,textBox.x), @floatToInt(c_int,textBox.y), @floatToInt(c_int,textBox.width), @floatToInt(c_int,textBox.height), ray.DARKGRAY);
        }

        ray.DrawText(dt, @floatToInt(c_int,textBox.x) + 5, @floatToInt(c_int,textBox.y) + 8, 15, ray.MAROON);
        for (buttons) |*b,i|{
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
    }
    exit = true;
}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!general_purpose_allocator.deinit());

    const alloc = general_purpose_allocator.allocator();
    sampler = initSampler(alloc); 
    defer sampler.freeAll();

    //try loadCmdLineArgSamples(alloc);

    try ma.createLowpass(alloc);
    //TODO:ugly to pass an allocator to free
    defer ma.destroyLowPass(alloc);

    ma.mix = mix;
    ma.exit = shouldExit;
    const audioThread = try std.Thread.spawn(.{}, ma.startAudio, .{});

    
    try loadSamplerConfig(alloc,&sampler);
    

    //TODO: just for now.. ui can't load samples
    _ = try std.Thread.spawn(.{}, userInput, .{&sampler});
    //Loop forever
    _ = try drawWindow(&sampler);
    try saveSamplerConfig(alloc);
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
        var b = try ma.loadAudioFile(alloc,arg1);
        sampler.load(b);
        alloc.free(arg1);
    }
}

fn userInput(samplers:*Sampler)!void{ 
    while (true){
        var buf: [1000]u8 = undefined;
        // We need a 0 terminated string... how unpleasant
        for (buf) |_,ii| buf[ii] = 0;
        const stdin = std.io.getStdIn().reader();
        if (try stdin.readUntilDelimiterOrEof(buf[0..], '\n')) |user_input| {
            const bla:[]u8 = user_input;
            if(ma.loadAudioFile(samplers.alloc,bla))|b|{
                samplers.load(b);
            }else |err|{
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        }
    }
}

fn loadSamplerConfig(alloc:std.mem.Allocator,samplers:*Sampler)!void{
    std.fs.cwd().makeDir("project1") catch {};
    const dir = try std.fs.cwd().openDir("project1",.{ .iterate = true });
    var rfile = try dir.openFile("sampler_config.json", .{});
    const body_content = try rfile.readToEndAlloc(alloc,std.math.maxInt(usize));
    defer alloc.free(body_content);
    defer rfile.close();

    var tokenStream = std.json.TokenStream.init(body_content);
    var newOne = try std.json.parse(SamplerW,&tokenStream,.{.allocator = alloc});
    defer std.json.parseFree(SamplerW,newOne,.{.allocator = alloc});

    for (samplers.sounds)|*snd,i|{
        const newSound = newOne.sounds[i];

        var str= try alloc.alloc(u8,newSound.name.len+1);
        defer alloc.free(str);
        str[newSound.name.len] = 0;
        for (newSound.name) |c,ii| str[ii] = c;
        if(ma.loadAudioFile(alloc,str))|b|{
                samplers.load(b);
            }else |err|{
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        snd.looping = newSound.looping;
        snd.reversed = newSound.reversed;
        snd.pitch = newSound.pitch;
        snd.semis = newSound.semis;
    }
}

fn saveSamplerConfig(alloc:std.mem.Allocator)!void{
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
  
    var sw:SamplerW = undefined;
    for (sw.sounds)|*snd,i|{
        const string = try std.fmt.allocPrint(arena.allocator(),"project1/snd_{d}.wav",.{i});
        snd.name = string;
        snd.looping = sampler.sounds[i].looping;
        snd.reversed = sampler.sounds[i].reversed;
        snd.pitch = sampler.sounds[i].pitch;
        snd.semis = sampler.sounds[i].semis;
        var str= try arena.allocator().alloc(u8,string.len+1);
        str[string.len] = 0;
        for (string) |c,ii| str[ii] = c;
        try ma.saveAudioFile(str,sampler.sounds[i].buffer);
    }
    
    std.fs.cwd().makeDir("project1") catch {};
    const dir = try std.fs.cwd().openDir("project1",.{ .iterate = true });
    var file = try dir.createFile("sampler_config.json", .{});
    defer file.close();
    const fw = file.writer();
    std.json.stringify(sw,std.json.StringifyOptions{.whitespace = null},fw)catch return;
}
