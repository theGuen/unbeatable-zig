const std = @import("std");
const math = @import("std").math;
const ma = @import("miniaudio.zig");
const settings = @import("settings.zig");
const sndFile = @import("sndFile.zig");

var m = std.Thread.Mutex{};
pub const Sampler = struct {
    alloc: std.mem.Allocator,
    selectedSound: usize,
    row: c_int,
    sounds: [64]Sound,
    pub fn load(self: *Sampler, sample: [][]f32, padNum: usize) void {
        self.selectedSound = padNum;
        var sound: *Sound = &self.sounds[self.selectedSound];
        //seems whe have to free the pointer last....
        const b = sound.buffer;
        sound.buffer = sample;
        sound.gain = 0.9;
        sound.posf = 0;
        sound.start = 0;
        sound.end = @floatFromInt(sound.buffer[0].len - 1);
        sound.reversed = false;
        sound.mutegroup = self.selectedSound;
        //std.debug.print("Loaded: {d}\n", .{self.selectedSound});
        if (b.len > 0) {
            self.alloc.free(b[0]);
            self.alloc.free(b[1]);
        }
        self.alloc.free(b);
    }
    pub fn deinit(self: *Sampler) void {
        for (&self.sounds) |*s| {
            const b = s.buffer;

            s.playing = false;
            s.posf = 0;
            s.start = 0;
            s.end = 0;
            s.buffer = &[_][]f32{};

            if (b.len > 0) {
                self.alloc.free(b[0]);
                self.alloc.free(b[1]);
            }
            self.alloc.free(b);
        }
    }
    pub fn play(self: *Sampler, soundIndex: usize, select: bool) void {
        m.lock();
        defer m.unlock();
        if (select) {
            self.selectedSound = soundIndex;
        }
        const mutegroup = self.sounds[soundIndex].mutegroup;
        for (&self.sounds, 0..) |*s, i| {
            if (s.mutegroup == mutegroup and i != soundIndex) {
                self.sounds[i].stop(true);
            }
        }
        self.sounds[soundIndex].play();
    }
    pub fn stop(self: *Sampler, soundIndex: usize) void {
        self.sounds[soundIndex].stop(false);
    }
    pub fn reverseSound(self: *Sampler) void {
        self.sounds[self.selectedSound].reverse();
    }
    pub fn isSoundReverse(self: *Sampler) bool {
        return self.sounds[self.selectedSound].reversed;
    }
    pub fn loopSound(self: *Sampler) void {
        self.sounds[self.selectedSound].looping = !self.sounds[self.selectedSound].looping;
    }
    pub fn isSoundLooping(self: *Sampler) bool {
        return self.sounds[self.selectedSound].looping;
    }
    pub fn gateSound(self: *Sampler) void {
        self.sounds[self.selectedSound].gated = !self.sounds[self.selectedSound].gated;
    }
    pub fn isSoundGated(self: *Sampler) bool {
        return self.sounds[self.selectedSound].gated;
    }
    pub fn setSoundMutegroup(self: *Sampler, mutegroup: usize) usize {
        self.sounds[self.selectedSound].mutegroup = mutegroup;
        return mutegroup;
    }
    pub fn getSoundMutegroup(self: *Sampler) usize {
        return self.sounds[self.selectedSound].mutegroup;
    }
    pub fn setSoundPitchSemis(self: *Sampler, semis: i64) i64 {
        self.sounds[self.selectedSound].semis = semis;
        self.sounds[self.selectedSound].pitch = pitchSemis(semis);
        std.debug.print("pitch: {d}\n", .{pitchSemis(semis)});
        return semis;
    }
    pub fn getSoundPitchSemis(self: *Sampler) i64 {
        return self.sounds[self.selectedSound].semis;
    }
    pub fn setSoundStart(self: *Sampler, start: i64) i64 {
        self.sounds[self.selectedSound].start = @floatFromInt(start);
        return start;
    }
    pub fn getSoundStart(self: *Sampler) i64 {
        return @intFromFloat(self.sounds[self.selectedSound].start);
    }
    pub fn setSoundEnd(self: *Sampler, end: i64) i64 {
        var sound = &self.sounds[self.selectedSound];
        sound.end = @floatFromInt(end);
        sound.posf = sound.end;
        return end;
    }
    pub fn getSoundEnd(self: *Sampler) i64 {
        return @intFromFloat(self.sounds[self.selectedSound].end);
    }
    pub fn getSoundSize(self: *Sampler) usize {
        var size = self.sounds[self.selectedSound].buffer[0].len;
        if (size > 0) size = size - 1;
        return size;
    }
    pub fn setSoundGain(self: *Sampler, gain: f32) f32 {
        var sound = &self.sounds[self.selectedSound];
        sound.gain = gain;
        return gain;
    }
    pub fn getSoundGain(self: *Sampler) f32 {
        return self.sounds[self.selectedSound].gain;
    }
    pub fn setSoundMixBus(self: *Sampler, bus: usize) usize {
        var sound = &self.sounds[self.selectedSound];
        sound.mixbus = bus;
        return bus;
    }
    pub fn getSoundMixBus(self: *Sampler) usize {
        return self.sounds[self.selectedSound].mixbus;
    }
    pub fn getSoundCurrentPos(self: *Sampler) i64 {
        return @intFromFloat(self.sounds[self.selectedSound].posf);
    }
    
    pub fn cropSound(self: *Sampler, src: usize) bool {
        const sound: *Sound = &self.sounds[src];
        sound.playing = false;
        const b = sound.buffer;
        const nb = cropSample(self.alloc, b, @intFromFloat(sound.start), @intFromFloat(sound.end)) catch return false;
        self.load(nb, src);
        sound.end = sound.end - sound.start - 1;
        sound.start = 0;
        return true;
    }
    pub fn copySound(self: *Sampler, src: usize, dest: usize) bool {
        const sound: *Sound = &self.sounds[src];
        var soundd = &self.sounds[dest];
        soundd.playing = false;
        const b = sound.buffer;
        if (b.len > 0) {
            const nb = copySample(self.alloc, b) catch return false;
            self.load(nb, dest);
        } else {
            soundd.buffer = &[_][]f32{};
        }

        soundd.gain = sound.gain;
        soundd.start = sound.start;
        soundd.end = sound.end;
        soundd.looping = sound.looping;
        soundd.reversed = sound.reversed;
        soundd.gated = sound.gated;
        soundd.pitch = sound.pitch;
        soundd.semis = sound.semis;
        soundd.mutegroup = sound.mutegroup;
        return true;
    }

    pub fn sliceSound(self: *Sampler, src: usize) bool {
        std.debug.print("slicing {d}\n", .{src});
        var dest = src;
        const sound: *Sound = &self.sounds[src];
        const b = sound.buffer;
        const tb = copySample(self.alloc, b) catch return false;
        defer {
            self.alloc.free(tb[0]);
            self.alloc.free(tb[1]);
            self.alloc.free(tb);
        }
        if (b.len > 0) {
            const newLength = b[0].len / 16;
            for (0..16) |x| {
                dest = src + x;
                var soundd = &self.sounds[dest];
                soundd.playing = false;
                std.debug.print("len {d} - from {d} to {d}, dest {d},\n", .{ tb[0].len, x * newLength, (x + 1) * newLength, dest });
                const nb = cropSample(self.alloc, tb, x * newLength, (x + 1) * newLength) catch return false;
                self.load(nb, dest);
                soundd.gain = sound.gain;
                soundd.start = 0;
                soundd.end = @floatFromInt(newLength - 1);
                soundd.looping = sound.looping;
                soundd.reversed = sound.reversed;
                soundd.gated = sound.gated;
                soundd.pitch = sound.pitch;
                soundd.semis = sound.semis;
                soundd.mutegroup = sound.mutegroup;
            }
        }
        return true;
    }
    pub fn incrementRow(self: *Sampler) c_int {
        if (self.row < 15) {
            self.row += 1;
        } else {
            self.row = 0;
        }
        return self.row;
    }
    pub fn decrementRow(self: *Sampler) c_int {
        if (self.row > 0) {
            self.row -= 1;
        } else {
            self.row = 15;
        }
        return self.row;
    }
};
pub fn initSampler(alloc: std.mem.Allocator) Sampler {
    var this = Sampler{ .alloc = alloc, .selectedSound = 0, .row = 0, .sounds = undefined };
    for (&this.sounds, 0..) |*s, i| {
        s.buffer = &[_][]f32{};
        s.posf = 0;
        s.gain = 1;
        s.start = 0;
        s.end = 0;
        s.playing = false;
        s.looping = false;
        s.reversed = false;
        s.gated = false;
        s.pitch = 1;
        s.semis = 0;
        s.mutegroup = i;
        s.mixbus = 0;
    }
    return this;
}

const Sound = struct {
    buffer: [][]f32,
    posf: f64,
    gain: f32,
    start: f64,
    end: f64,
    playing: bool,
    looping: bool,
    reversed: bool,
    gated: bool,
    pitch: f32,
    semis: i64,
    mutegroup: usize,
    mixbus: usize,
    pub fn next(p: *Sound) [2]f32 {
        var l: usize = 0;
        var r: usize = 1;
        var retval = [2]f32{ 0, 0 };
        if (p.buffer.len > 0 and p.playing) {
            const ende = p.end;
            const start = p.start;
            if (p.posf > ende and !p.reversed) {
                p.posf = p.posf - ende + start;
                if (!p.looping) p.playing = false;
            } else if (p.posf < start and p.reversed) {
                p.posf = ende - (start - p.posf);
                if (!p.looping) p.playing = false;
            }
            const pos: i64 = @intFromFloat(p.posf);
            if (!p.reversed) {
                p.posf += p.pitch;
            } else {
                l = 1;
                r = 0;
                p.posf -= p.pitch;
            }
            retval[0] = p.buffer[l][@intCast(pos)] * p.gain;
            retval[1] = p.buffer[r][@intCast(pos)] * p.gain;
            return retval;
        } else {
            return retval;
        }
    }
    fn play(p: *Sound) void {
        if (!p.reversed) {
            p.posf = p.start;
        } else {
            p.posf = p.end;
        }
        if (p.playing and p.looping) {
            p.playing = false;
        } else {
            p.playing = true;
        }
    }
    fn stop(p: *Sound, force: bool) void {
        if (p.gated or force) {
            p.playing = false;
            if (!p.reversed) {
                p.posf = p.start;
            } else {
                p.posf = p.end;
            }
        }
    }
    fn reverse(p: *Sound) void {
        p.reversed = !p.reversed;
        if (!p.reversed) {
            p.posf = p.start;
        } else {
            p.posf = p.end;
        }
    }
};

//One for writing one for loading...extend your project
const SamplerW = struct { sounds: [64]SoundW };
const SoundW = struct {
    name: []u8,
    gain: f32,
    start: f64,
    end: f64,
    looping: bool,
    reversed: bool,
    gated: bool,
    pitch: f32,
    semis: i64,
    mutegroup: usize,
    mixbus: usize,
};
const SamplerL = struct { sounds: [64]SoundL };
const SoundL = struct {
    name: []u8,
    gain: f32,
    start: f64,
    end: f64,
    looping: bool,
    reversed: bool,
    gated: bool,
    pitch: f32,
    semis: i64,
    mutegroup: usize,
    mixbus: usize,
};

fn pitchSemis(pitch: i64) f32 {
    const pitchstep = 1.05946;
    const abs: u64 = @abs(pitch);
    var oct = abs / 12;
    const semi = abs - (12 * oct);
    oct += 1;
    var p: f32 = 0.0;
    if (pitch < 0) {
        p = math.pow(f32, pitchstep, @as(f32, @floatFromInt((12 - semi))));
        p = p * 1 / math.pow(f32, 2, @as(f32, @floatFromInt(oct)));
    } else if (pitch > 0 and pitch < 12) {
        p = math.pow(f32, pitchstep, @as(f32, @floatFromInt(semi)));
        p = p * @as(f32, @floatFromInt(oct));
    } else if (pitch == 12) {
        p = 2;
    } else if (pitch > 12) {
        p = 2.1;
    } else {
        p = 1;
    }
    return p;
}

pub fn loadDefaultSamplerConfig(alloc: std.mem.Allocator, samplers: *Sampler) !void {
    const projectName = settings.currentProj;
    std.fs.cwd().makeDir(projectName) catch {};
    loadSamplerConfig(alloc, samplers, projectName) catch {};
}
pub fn loadSamplerConfig(alloc: std.mem.Allocator, samplers: *Sampler, projectName: []u8) !void {
    //const dir = std.fs.cwd().openIterableDir(projectName, .{}) catch return {};
    const dirinit = std.fs.cwd().openDir(projectName, .{}) catch return {};
    var dir = dirinit.iterate();
    var rfile = dir.dir.openFile("sampler_config.json", .{}) catch return {};
    const body_content = try rfile.readToEndAlloc(alloc, std.math.maxInt(usize));
    defer alloc.free(body_content);
    defer rfile.close();

    const parsed = try std.json.parseFromSlice(SamplerL, alloc, body_content, .{});
    defer parsed.deinit();
    const newOne = parsed.value;

    for (&samplers.sounds, 0..) |*snd, i| {
        const newSound = newOne.sounds[i];
        if (newSound.end != 0) {
            var str = try alloc.alloc(u8, newSound.name.len + 1);
            defer alloc.free(str);
            str[newSound.name.len] = 0;
            for (newSound.name, 0..) |c, ii| str[ii] = c;
            if (ma.loadAudioFile(alloc, str)) |b| {
                const split = try splitSample(alloc, b, b.len);
                samplers.load(split, i);
            } else |err| {
                std.debug.print("ERROR: {s}\n", .{@errorName(err)});
            }
        }
        snd.gain = newSound.gain;
        snd.start = newSound.start;
        snd.end = newSound.end;
        snd.looping = newSound.looping;
        snd.reversed = newSound.reversed;
        snd.gated = newSound.gated;
        snd.pitch = newSound.pitch;
        snd.semis = newSound.semis;
        snd.mutegroup = newSound.mutegroup;
        snd.mixbus = newSound.mixbus;
    }
    samplers.selectedSound = 0;
}

pub fn saveSamplerConfig(alloc: std.mem.Allocator, sampler: *Sampler) !void {
    var arena = std.heap.ArenaAllocator.init(alloc);
    defer arena.deinit();

    var sw: SamplerW = undefined;
    for (&sw.sounds, 0..) |*snd, i| {
        const string = try std.fmt.allocPrint(arena.allocator(), "{s}/snd_{d}.wav", .{ settings.currentProj, i });
        snd.name = string;
        snd.gain = sampler.sounds[i].gain;
        snd.start = sampler.sounds[i].start;
        snd.end = sampler.sounds[i].end;
        snd.looping = sampler.sounds[i].looping;
        snd.reversed = sampler.sounds[i].reversed;
        snd.gated = sampler.sounds[i].gated;
        snd.pitch = sampler.sounds[i].pitch;
        snd.semis = sampler.sounds[i].semis;
        snd.mutegroup = sampler.sounds[i].mutegroup;
        snd.mixbus = sampler.sounds[i].mixbus;
        var str = try arena.allocator().alloc(u8, string.len + 1);
        str[string.len] = 0;
        for (string, 0..) |c, ii| str[ii] = c;
        const join = try joinSample(arena.allocator(), sampler.sounds[i].buffer);
        if (sampler.sounds[i].start != sampler.sounds[i].end) {
            try ma.saveAudioFile(str, join);
        }
    }

    std.fs.cwd().makeDir(settings.currentProj) catch {};
    //const dir = try std.fs.cwd().openIterableDir(settings.currentProj, .{});
    const dirinit = std.fs.cwd().openDir(settings.currentProj, .{}) catch return {};
    var dir = dirinit.iterate();
    var file = try dir.dir.createFile("sampler_config.json", .{});
    defer file.close();
    const fw = file.writer();
    std.json.stringify(sw, .{ .whitespace = .indent_2 }, fw) catch return;
}

pub fn copySample(alloc: std.mem.Allocator, sample: [][]f32) ![][]f32 {
    var ret = try alloc.alloc([]f32, sample.len);
    const l = try alloc.alloc(f32, sample[0].len);
    const r = try alloc.alloc(f32, sample[1].len);
    for (l, 0..) |*s, i| {
        s.* = sample[0][i];
    }
    for (r, 0..) |*s, i| {
        s.* = sample[1][i];
    }
    ret[0] = l;
    ret[1] = r;
    return ret;
}
pub fn cropSample(alloc: std.mem.Allocator, sample: [][]f32, from: usize, to: usize) ![][]f32 {
    var ret = try alloc.alloc([]f32, to - from);
    const l = try alloc.alloc(f32, to - from);
    const r = try alloc.alloc(f32, to - from);
    for (l, 0..) |*s, i| {
        s.* = sample[0][from + i];
    }
    for (r, 0..) |*s, i| {
        s.* = sample[1][from + i];
    }
    ret[0] = l;
    ret[1] = r;
    return ret;
}
pub fn splitSample(alloc: std.mem.Allocator, sample: []f32, slen: usize) ![][]f32 {
    //TODO: maybe not my job
    defer alloc.free(sample);
    const splitLen: usize = slen / 2;
    const sam = sample;
    var l = try alloc.alloc(f32, splitLen);
    var r = try alloc.alloc(f32, splitLen);
    var ret = try alloc.alloc([]f32, 2);
    for (l, 0..) |_, i| {
        if (i == splitLen) break;
        l[i] = sam[i * 2];
        r[i] = sam[i * 2 + 1];
    }
    ret[0] = l;
    ret[1] = r;
    return ret;
}

pub fn joinSample(alloc: std.mem.Allocator, sample: [][]f32) ![]f32 {
    if (sample.len > 0) {
        var ret = try alloc.alloc(f32, sample[0].len * 2);
        for (sample[0], 0..) |_, i| {
            ret[i * 2] = sample[0][i];
            ret[i * 2 + 1] = sample[1][i];
        }
        return ret;
    }
    return &[_]f32{};
}
