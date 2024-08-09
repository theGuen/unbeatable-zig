const std = @import("std");
const smplr = @import("sampler.zig");
const tim = @cImport(@cInclude("timer.h"));
const settings = @import("settings.zig");

pub var sequencer: Sequencer = undefined;

fn tick_callback(b: c_int) callconv(.C) void {
    _ = b;
    sequencer.tick();
}

pub const SequencerEvent = struct {
    timeCode: i64,
    padNumber: usize,
};

pub const Sequencer = struct {
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
    recordList: std.ArrayList(SequencerEvent),
    prepared: bool,
    recording: bool,
    playing: bool,
    currentTick: i64,
    micros: c_int,
    pub fn startRecording(self: *Sequencer) void {
        if (!self.recording) {
            //self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);
            self.recording = true;
            self.playing = true;
            self.currentTick = -1;
        }
    }
    pub fn startPlaying(self: *Sequencer) void {
        if (!self.recording) {
            self.currentTick = -1;
            self.playing = true;
        }
    }
    pub fn stopPlaying(self: *Sequencer) void {
        self.playing = false;
    }
    pub fn stopRecording(self: *Sequencer) void {
        self.recording = false;
        self.playing = false;
        // debug
        var clone = self.recordList.clone() catch return;
        const sl = clone.toOwnedSlice() catch return;
        const js = std.json.stringifyAlloc(
            self.alloc,
            sl,
            .{ .whitespace = .indent_2 },
        ) catch return;
        std.debug.print("Seq: {s}\n", .{js});
        self.alloc.free(js);
        self.alloc.free(sl);
    }
    pub fn clearRecording(self: *Sequencer) void {
        if (!self.recording) {
            self.recordList.deinit();
            self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);
        }
    }
    pub fn setBPM(self: *Sequencer) void {
        tim.stopTimer();
        const c: c_int = @divFloor(settings.minute, settings.bpm * settings.ppq);
        self.micros = c;
        tim.startTimer(c, tick_callback);
    }
    pub fn appendToRecord(self: *Sequencer, pad: usize) void {
        if (self.recording) {
            self.recordList.append(SequencerEvent{ .timeCode = self.currentTick, .padNumber = pad }) catch return {};
        }
    }
    pub fn appendalways(self: *Sequencer, pad: usize, onTick: i64) void {
        self.recordList.append(SequencerEvent{ .timeCode = onTick, .padNumber = pad }) catch return {};
    }
    pub fn tick(self: *Sequencer) void {
        if (self.playing) {
            self.playForTimeCode(self.currentTick);
        }
        if (self.recording or self.playing) {
            self.currentTick += 1;
        }
    }
    fn playForTimeCode(self: *Sequencer, timeCode: i64) void {
        for (self.recordList.items) |evt| {
            if (evt.timeCode == timeCode) {
                self.sampler.play(evt.padNumber, false);
            }
        }
    }
    pub fn deletePad(self: *Sequencer, pad: usize) void {
        var old = self.recordList;
        defer old.deinit();
        self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);
        for (old.items) |evt| {
            if (evt.padNumber != pad) {
                self.recordList.append(evt) catch return {};
            }
        }
    }
    pub fn quantize(self: *Sequencer) void {
        for (self.recordList.items) |*evt| {
            if (evt.timeCode < 0) {
                evt.timeCode = 0;
                continue;
            }
            var x = @divFloor(evt.timeCode, settings.ppq / 4);
            var new = x * (settings.ppq / 4);
            if (evt.timeCode - new > settings.ppq / 8) {
                new = (x + 1) * (settings.ppq / 4);
            }
            evt.timeCode = new;
        }
    }
};

pub fn newSequencer(
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
) Sequencer {
    const c: c_int = @divFloor(settings.minute, settings.bpm * settings.ppq);
    tim.startTimer(c, tick_callback);
    const this = Sequencer{ .alloc = alloc, .recordList = std.ArrayList(SequencerEvent).init(alloc), .prepared = false, .playing = false, .recording = false, .sampler = sampler, .currentTick = -1, .micros = c };
    sequencer = this;
    return this;
}

pub fn saveSequence(seq: *Sequencer) !void {
    std.fs.cwd().makeDir(settings.currentProj) catch {};
    const dir = try std.fs.cwd().openIterableDir(settings.currentProj, .{});
    var file = try dir.dir.createFile("sequence.json", .{});
    defer file.close();
    const fw = file.writer();
    var clone = seq.recordList.clone() catch return;
    const sl = clone.toOwnedSlice() catch return;
    std.json.stringify(sl, .{ .whitespace = .indent_2 }, fw) catch return;
    seq.alloc.free(sl);
}

pub fn loadSequence(seq: *Sequencer, alloc: std.mem.Allocator, projectName: []u8) !void {
    std.debug.print("INFO: loading sequence\n", .{});
    const dir = std.fs.cwd().openIterableDir(projectName, .{}) catch return {};
    var rfile = dir.dir.openFile("sequence.json", .{}) catch return {};
    const body_content = try rfile.readToEndAlloc(alloc, std.math.maxInt(usize));

    std.debug.print("INFO: read sequence\n", .{});
    defer alloc.free(body_content);
    defer rfile.close();

    const parsed = try std.json.parseFromSlice([]SequencerEvent, alloc, body_content, .{});
    std.debug.print("INFO: parsed sequence\n", .{});
    defer parsed.deinit();
    seq.clearRecording();
    const newOne = parsed.value;
    for (newOne) |entry| {
        seq.recordList.append(SequencerEvent{ .timeCode = entry.timeCode, .padNumber = entry.padNumber }) catch return {};
    }
}
