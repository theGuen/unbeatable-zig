const std = @import("std");
const math = @import("std").math;
const ma = @import("miniaudio.zig");


pub const Sampler = struct{
    alloc: std.mem.Allocator,
    selectedSound: usize,
    sounds: [16]Sound,
    pub fn load(self: *Sampler, sample: *[]f32)void{
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
    pub fn freeAll(self: *Sampler)void{
        for (self.sounds) |*s|{
            var b = s.buffer;
            defer self.alloc.free(b);

            s.playing =false;
            s.posf = 0;
            s.buffer = &[_]f32{};
        }
    }
    pub fn play(self: *Sampler,soundIndex:usize)void{
        self.selectedSound = soundIndex;
        self.sounds[soundIndex].play();
    }
    pub fn stop(self: *Sampler,soundIndex:usize)void{
        self.sounds[soundIndex].stop();
    }
    pub fn reverseSound(self: *Sampler)void{
        self.sounds[self.selectedSound].reverse();
    }
    pub fn isSoundReverse(self: *Sampler)bool{
        return self.sounds[self.selectedSound].reversed;
    }
    pub fn loopSound(self: *Sampler)void{
        self.sounds[self.selectedSound].looping= !self.sounds[self.selectedSound].looping;
    }
    pub fn isSoundLooping(self: *Sampler)bool{
        return self.sounds[self.selectedSound].looping;
    }
    pub fn gateSound(self: *Sampler)void{
        self.sounds[self.selectedSound].gated= !self.sounds[self.selectedSound].gated;
    }
    pub fn isSoundGated(self: *Sampler)bool{
        return self.sounds[self.selectedSound].gated;
    }
    pub fn pitchSoundSemis(self: *Sampler,semisToPitch:i64)void{
        self.sounds[self.selectedSound].pitchSemis= semisToPitch;
        self.sounds[self.selectedSound].pitch= pitchSemis(semisToPitch);
    }

};
pub fn initSampler(alloc: std.mem.Allocator)Sampler{
    var this = Sampler{.alloc = alloc,.selectedSound=0,.sounds=undefined};
    for (this.sounds) |*s|{
        s.buffer = &[_]f32{}; 
        s.posf = 0;
        s.playing = false;
        s.looping = false;
        s.reversed = false;
        s.gated = false;
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
    gated: bool,
    pitch :f32,
    semis:i64,
    pub fn next(p:*Sound)f32{
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
        if (p.gated){
            p.playing = false;
            if (!p.reversed){
                p.posf = 0;
            }else{
                p.posf = @intToFloat(f64,p.buffer.len-1);
            }
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

//One for writing one for loading...extend your project
const SamplerW = struct{
    sounds: [16]SoundW
};
const SoundW = struct{
    name : []u8,
    looping :bool,
    reversed: bool,
    gated: bool,
    pitch :f32,
    semis:i64
};
const SamplerL = struct{
    sounds: [16]SoundL
};
const SoundL = struct{
    name : []u8,
    looping :bool,
    reversed: bool,
    gated: bool,
    pitch :f32,
    semis:i64
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

pub fn loadSamplerConfig(alloc:std.mem.Allocator,samplers:*Sampler)!void{
    std.fs.cwd().makeDir("project1") catch {};
    const dir = try std.fs.cwd().openDir("project1",.{ .iterate = true });
    var rfile = try dir.openFile("sampler_config.json", .{});
    const body_content = try rfile.readToEndAlloc(alloc,std.math.maxInt(usize));
    defer alloc.free(body_content);
    defer rfile.close();

    var tokenStream = std.json.TokenStream.init(body_content);
    var newOne = try std.json.parse(SamplerL,&tokenStream,.{.allocator = alloc});
    defer std.json.parseFree(SamplerL,newOne,.{.allocator = alloc});

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
        snd.reversed = newSound.gated;
        snd.pitch = newSound.pitch;
        snd.semis = newSound.semis;
    }
}

pub fn saveSamplerConfig(alloc:std.mem.Allocator,sampler:*Sampler)!void{
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();
  
    var sw:SamplerW= undefined;
    for (sw.sounds)|*snd,i|{
        const string = try std.fmt.allocPrint(arena.allocator(),"project1/snd_{d}.wav",.{i});
        snd.name = string;
        snd.looping = sampler.sounds[i].looping;
        snd.reversed = sampler.sounds[i].reversed;
        snd.gated = sampler.sounds[i].gated;
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