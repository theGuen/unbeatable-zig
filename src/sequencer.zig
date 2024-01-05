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
    recording: bool,
    playing: bool,
    currentTick: i64,
    micros: c_int,
    pub fn startRecording(self: *Sequencer) void {
        if (!self.recording) {
            self.recordList = std.ArrayList(SequencerEvent).init(self.alloc);
            self.recording = true;
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

        // debug
        var clone = self.recordList.clone() catch return;
        var sl = clone.toOwnedSlice() catch return;
        var js = std.json.stringifyAlloc(
            self.alloc,
            sl,
            .{ .whitespace = .indent_2 },
        ) catch return;
        std.debug.print("Seq: {s}\n", .{js});
        self.alloc.free(js);
        self.alloc.free(sl);
    }
    pub fn clearRecording(self: *Sequencer) void {
        if (!self.recording) self.recordList.deinit();
    }
    pub fn appendToRecord(self: *Sequencer, pad: usize) void {
        if (self.recording) {
            self.recordList.append(SequencerEvent{ .timeCode = self.currentTick, .padNumber = pad }) catch return {};
        }
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
};

pub fn newSequencer(
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
) Sequencer {
    var c: c_int = @divFloor(settings.minute, settings.bpm * settings.ppq);
    tim.startTimer(c, tick_callback);
    var this = Sequencer{ .alloc = alloc, .recordList = std.ArrayList(SequencerEvent).init(alloc), .playing = false, .recording = false, .sampler = sampler, .currentTick = -1, .micros = c };
    sequencer = this;
    return this;
}

pub fn saveSequence(seq: *Sequencer) !void {
    std.fs.cwd().makeDir(settings.defaultProj) catch {};
    const dir = try std.fs.cwd().openIterableDir(settings.defaultProj, .{});
    var file = try dir.dir.createFile("sequence.json", .{});
    defer file.close();
    const fw = file.writer();
    var clone = seq.recordList.clone() catch return;
    var sl = clone.toOwnedSlice() catch return;
    std.json.stringify(sl, .{ .whitespace = .indent_2 }, fw) catch return;
    seq.alloc.free(sl);
}
