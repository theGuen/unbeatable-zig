const std = @import("std");
const smplr = @import("sampler.zig");
const tim = @cImport(@cInclude("timer.h"));
const settings = @import("settings.zig");

pub var sequencer: Sequencer = undefined;
var loading = false;

fn tick_callback(b: c_int) callconv(.C) void {
    _ = b;
    sequencer.tick();
}

const EventType = enum {
    note_on,
    note_off,
    cc_evt,
};

pub const SequencerEvent = struct {
    timeCode: i64,
    padNumber: usize,
    //Not used right now
    eventType: EventType,
    length: i64,
    gated: bool,
    pitch: f32,
    semis: i64,
    pan: f32,
    cc_val: usize,
};

pub fn NewSequencerEvent(timeCode: i64, padNumber: usize, eventType: EventType) SequencerEvent {
    return SequencerEvent{ .timeCode = timeCode, .padNumber = padNumber, .eventType = eventType, .length = settings.ppq * 4, .gated = false, .pitch = 0, .semis = 0, .pan = 0.5, .cc_val = 0 };
}

pub const Sequencer = struct {
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
    recordList: std.ArrayList(SequencerEvent),
    pattern: [16][]SequencerEvent,
    currentPattern: usize,
    nextPattern: usize,
    prepared: bool,
    recording: bool,
    playing: bool,
    currentTick: i64,
    micros: c_int,
    stepMode: bool,
    numBars: usize,
    curBar: usize,
    nudge: i64,
    pub fn startRecording(self: *Sequencer) void {
        if (!self.recording) {
            self.recording = true;
            self.playing = true;
            self.currentTick = 0;
        }
    }
    pub fn startPlaying(self: *Sequencer) void {
        self.loadCurrentPattern();
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
        self.sort();
        var clone = self.recordList.clone() catch return;
        const sl = clone.toOwnedSlice() catch return;
        self.pattern[self.currentPattern] = sl;
    }
    pub fn clearRecording(self: *Sequencer) void {
        if (!self.recording) {
            self.recordList.deinit();
            self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);
        }
        var clone = self.recordList.clone() catch return;
        const sl = clone.toOwnedSlice() catch return;
        self.pattern[self.currentPattern] = sl;
    }
    pub fn setBPM(self: *Sequencer) void {
        tim.stopTimer();
        const c: c_int = @divFloor(settings.minute, settings.bpm * settings.ppq);
        self.micros = c;
        tim.startTimer(c, tick_callback);
    }
    pub fn setStepMode(self: *Sequencer, stepMode: bool) void {
        self.stepMode = stepMode;
        if (!stepMode) {
            self.sort();
            var clone = self.recordList.clone() catch return;
            const sl = clone.toOwnedSlice() catch return;
            self.pattern[self.currentPattern] = sl;
        }
    }
    pub fn appendToRecord(self: *Sequencer, pad: usize) void {
        if (self.recording) {
            self.recordList.append(NewSequencerEvent(self.currentTick, pad, EventType.note_on)) catch return {};
        }
    }
    pub fn appendalways(self: *Sequencer, pad: usize, onTick: i64) void {
        self.recordList.append(NewSequencerEvent(onTick, pad, EventType.note_on)) catch return {};
    }
    pub fn toggle(self: *Sequencer, pad: usize, onTick: i64) void {
        var found: ?usize = null;
        for (0..self.recordList.items.len) |i| {
            const evt = self.recordList.items[i];
            const tmp = @divTrunc(evt.timeCode, (settings.ppq / 4)) * (settings.ppq / 4);
            if (tmp == onTick and evt.padNumber == pad) {
                std.debug.print("true {} {} {}\n", .{ evt.padNumber, tmp, onTick });
                found = i;
                break;
            }
        }
        if (found == null) {
            const onTickTmp = onTick + @as(i64, @intCast(self.nudge));
            self.recordList.append(NewSequencerEvent(onTickTmp, pad, EventType.note_on)) catch return;
        } else {
            std.debug.print("len {}\n", .{self.recordList.items.len});
            const removed = self.recordList.orderedRemove(found.?);
            std.debug.print("true {}\n", .{removed});
            std.debug.print("len {}\n", .{self.recordList.items.len});
        }
        if (onTick >= self.numBars * settings.ppq * 4) {
            const tmp: usize = self.numBars * @as(usize, settings.ppq * 4);
            self.numBars = @as(usize, @intCast(onTick)) / tmp + 1;
        }
    }
    pub fn tick(self: *Sequencer) void {
        if (self.playing and !loading) {
            self.playForTimeCode(self.currentTick);
        }
        if (self.recording or self.playing) {
            self.currentTick += 1;
        }
        if (self.currentTick > settings.ppq * 4 * self.numBars) {
            self.currentTick = 0;
            if (self.currentPattern != self.nextPattern) {
                self.setCurrentPattern(self.nextPattern);
            }
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
            const x = @divFloor(evt.timeCode, settings.ppq / 4);
            var new = x * (settings.ppq / 4);
            if (evt.timeCode - new > settings.ppq / 8) {
                new = (x + 1) * (settings.ppq / 4);
            }
            evt.timeCode = new;
        }
    }
    fn sort(self: *Sequencer) void {
        // Sort the content by timecode
        const x = self.recordList.toOwnedSlice() catch return;
        std.sort.insertion(SequencerEvent, x, {}, compareSequencerEvent);
        self.recordList.deinit();
        self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);
        for (x) |item| {
            self.recordList.append(item) catch return;
        }

        // debug
        // var clone = self.recordList.clone() catch return;
        // const sl = clone.toOwnedSlice() catch return;
        // const js = std.json.stringifyAlloc(
        //     self.alloc,
        //     sl,
        //     .{ .whitespace = .indent_2 },
        // ) catch return;
        // std.debug.print("Seq: {s}\n", .{js});
        // self.alloc.free(js);
        // self.alloc.free(sl);
    }
    pub fn setCurrentPattern(self: *Sequencer, pattern: usize) void {
        self.currentPattern = pattern;
        loading = true;
        self.loadCurrentPattern();
        loading = false;
    }
    pub fn setNextPattern(self: *Sequencer, pattern: usize) void {
        self.nextPattern = pattern;
        if (!self.playing) {
            self.setCurrentPattern(pattern);
        }
    }
    pub fn loadCurrentPattern(self: *Sequencer) void {
        self.recordList.deinit();
        self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);

        const oneBar: usize = @as(usize, settings.ppq * 4);
        var lastTimeCode: i64 = 0;
        for (self.pattern[self.currentPattern]) |entry| {
            self.recordList.append(NewSequencerEvent(entry.timeCode, entry.padNumber, EventType.note_on)) catch return {};
            lastTimeCode = entry.timeCode;
        }
        self.numBars = @as(usize, @intCast(lastTimeCode)) / oneBar + 1;
        std.debug.print("loadCurrentPattern {}\n", .{self.recordList.items.len});
    }
    pub fn sixteenth(self: *Sequencer, pad: usize, cur_row: usize) [16]bool {
        var retval = [16]bool{ false, false, false, false, false, false, false, false, false, false, false, false, false, false, false, false };
        if (loading) return retval;
        for (self.recordList.items) |*evt| {
            const pps = (settings.ppq / 4);
            if (evt.timeCode < 0) continue;
            const index: usize = @intCast(@divFloor(evt.timeCode, pps));
            const bar = cur_row / 4;
            if (evt.padNumber == pad and index >= bar * 16 and index < (bar + 1) * 16) {
                retval[index - (bar * 16)] = true;
            }
        }
        return retval;
    }
    pub fn incrementRow(self: *Sequencer) usize {
        if (self.curBar < 15) {
            self.curBar += 1;
        } else {
            self.curBar = 0;
        }
        return self.curBar;
    }
    pub fn decrementRow(self: *Sequencer) usize {
        if (self.curBar > 0) {
            self.curBar -= 1;
        } else {
            self.curBar = 15;
        }
        return self.curBar;
    }
    pub fn incrementNudge(self: *Sequencer) i64 {
        const maxNudge = settings.ppq / 4;
        if (self.nudge < maxNudge - 1) {
            self.nudge += 1;
        } else {
            self.nudge = 0;
        }
        return self.nudge;
    }
    pub fn decrementNudge(self: *Sequencer) i64 {
        const maxNudge = settings.ppq / 4;
        if (self.nudge > 0) {
            self.nudge -= 1;
        } else {
            self.nudge = maxNudge - 1;
        }
        return self.nudge;
    }
};

pub fn newSequencer(
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
) Sequencer {
    const c: c_int = @divFloor(settings.minute, settings.bpm * settings.ppq);
    tim.startTimer(c, tick_callback);
    const this = Sequencer{ .alloc = alloc, .recordList = std.ArrayList(SequencerEvent).init(alloc), .pattern = undefined, .currentPattern = 0, .nextPattern = 0, .prepared = false, .playing = false, .recording = false, .sampler = sampler, .currentTick = -1, .micros = c, .stepMode = false, .numBars = 1, .curBar = 0, .nudge = 0 };
    sequencer = this;
    return this;
}

fn compareSequencerEvent(_: void, lhs: SequencerEvent, rhs: SequencerEvent) bool {
    return lhs.timeCode < rhs.timeCode;
}

const SaveSeq = struct { bpm: c_int, pattern: [16][]SequencerEvent };

pub fn saveSequence(seq: *Sequencer) !void {
    std.fs.cwd().makeDir(settings.currentProj) catch {};
    //const dir = try std.fs.cwd().openIterableDir(settings.currentProj, .{});
    const dirinit = std.fs.cwd().openDir(settings.currentProj, .{}) catch return {};
    var dir = dirinit.iterate();
    var file = try dir.dir.createFile("sequence.json", .{});
    defer file.close();
    const fw = file.writer();

    var clone = seq.recordList.clone() catch return;
    const sl = clone.toOwnedSlice() catch return;
    seq.pattern[seq.currentPattern] = sl;

    const toSave = SaveSeq{ .bpm = settings.bpm, .pattern = seq.pattern };
    std.json.stringify(toSave, .{ .whitespace = .indent_2 }, fw) catch return;
}

pub fn loadSequence(seq: *Sequencer, alloc: std.mem.Allocator, projectName: []u8) !void {
    std.debug.print("INFO: loading sequence\n", .{});
    //const dir = std.fs.cwd().openIterableDir(projectName, .{}) catch return {};
    const dirinit = std.fs.cwd().openDir(projectName, .{}) catch return {};
    var dir = dirinit.iterate();
    var rfile = dir.dir.openFile("sequence.json", .{}) catch return {};
    const body_content = try rfile.readToEndAlloc(alloc, std.math.maxInt(usize));

    std.debug.print("INFO: read sequences\n", .{});
    defer alloc.free(body_content);
    defer rfile.close();

    const parsed = try std.json.parseFromSlice(SaveSeq, alloc, body_content, .{});
    std.debug.print("INFO: parsed sequences\n", .{});
    defer parsed.deinit();
    seq.clearRecording();
    const newOne = parsed.value;
    for (newOne.pattern, 0..) |p, i| {
        const r = try alloc.alloc(SequencerEvent, p.len);
        for (p, 0..) |evt, j| {
            r[j] = NewSequencerEvent(evt.timeCode, evt.padNumber, EventType.note_on);
        }
        seq.pattern[i] = r;
    }
    seq.loadCurrentPattern();
}
