const std = @import("std");

pub const Recorder = struct {
    alloc: std.mem.Allocator,
    recordList: std.ArrayList([]f32),
    recording: bool,
    pub fn startRecording(self: *Recorder) void {
        self.recordList = std.ArrayList([]f32).init(self.alloc);
        self.recording = true;
    }
    pub fn stopRecording(self: *Recorder) []f32 {
        self.recording = false;
        var length: usize = 0;
        for (self.recordList.items) |buf| {
            length += buf.len;
        }
        var pos: usize = 0;
        var rb = self.alloc.alloc(f32, length) catch return &[_]f32{};
        for (self.recordList.items) |buf| {
            for (buf, 0..) |_, i| rb[i + pos] = buf[i];
            pos += buf.len;
            self.alloc.free(buf);
        }
        self.recordList.deinit();
        return rb;
    }
    pub fn appendToRecord(self: *Recorder, recordbuffer: []f32) void {
        if (self.recording) {
            self.recordList.append(recordbuffer) catch return {};
        } else {
            self.alloc.free(recordbuffer);
        }
    }
};

pub fn newRecorder(alloc: std.mem.Allocator) Recorder {
    var this = Recorder{ .alloc = alloc, .recordList = undefined, .recording = false };
    return this;
}
