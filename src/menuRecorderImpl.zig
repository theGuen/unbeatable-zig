const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const h = @import("helper.zig");
const ma = @import("miniaudio.zig");
const seq = @import("sequencer.zig");
const mn = @import("menu.zig");
const settings = @import("settings.zig");

fn uprecord(self: *RecorderValue) void {
    if (!self.recorder.recording) {
        if (self.loaded) {
            self.recorder.startRecording();
        } else {
            self.state.stateValInt = @intCast(self.sampler.selectedSound);
            self.loaded = true;
        }
    }
}
fn downrecord(self: *RecorderValue) void {
    if (self.recorder.recording) {
        const recorded = self.recorder.stopRecording();
        const split = smplr.splitSample(self.recorder.alloc, recorded, recorded.len) catch return {};
        self.sampler.load(split, @intCast(self.state.stateValInt));
        self.loaded = false;
        self.sampler.play(@intCast(self.state.stateValInt), true);
    } else {
        self.loaded = false;
    }
}
fn currentrecord(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.recorder.recording) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Pad {d}: recording...", .{self.state.stateValInt}) catch "";
    } else {
        if (!self.loaded) {
            self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: Pad {d}", .{ self.label, self.sampler.selectedSound }) catch "";
        } else {
            self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Pad {d}: armed...", .{self.state.stateValInt}) catch "";
        }
    }
    return @ptrCast(self.state.stateValStr);
}

fn upLineIn(self: *RecorderValue) void {
    self.recorder.lineIn = true;
}
fn downLineIn(self: *RecorderValue) void {
    self.recorder.lineIn = false;
}
fn currentLineIn(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.recorder.lineIn) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Line in enabled", .{}) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Line in disabled", .{}) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

fn uprecseq(self: *RecorderValue) void {
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "sequence prepared", .{}) catch "";
    self.state.stateValInt = 1;
    self.sequencer.setBPM();
    self.sequencer.prepared = true;
}
fn downrecseq(self: *RecorderValue) void {
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "record sequence", .{}) catch "";
    self.state.stateValInt = 0;
    self.sequencer.stopRecording();
    self.sequencer.prepared = false;
}
fn currentrecseq(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt == 1) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "sequence prepared", .{}) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "record sequence", .{}) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}


fn upclickTrack(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    for (0..self.sequencer.numBars * 4) |x| {
        self.sequencer.appendalways(self.sampler.selectedSound, @intCast(x * settings.ppq));
    }
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "creating clicktrack", .{}) catch "";
}
fn downclickTrack(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "clicktrack Pad: {}", .{self.sampler.selectedSound}) catch "";
}
fn currentclickTrack(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "clicktrack Pad: {}", .{self.sampler.selectedSound}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upQuant(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.sequencer.quantize();
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Quantize 1/16", .{}) catch "";
}
fn downQuant(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Quantize 1/16", .{}) catch "";
}
fn currentQuant(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Quantize 1/16", .{}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upDelAll(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.sequencer.deletePad(self.sampler.selectedSound);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Delete All Pad {d}", .{self.sampler.selectedSound}) catch "";
}
fn downDelAll(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Delete All Pad {d}", .{self.sampler.selectedSound}) catch "";
}
fn currentDelAll(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "Delete All Pad {d}", .{self.sampler.selectedSound}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn updelseq(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = 1;
    self.sequencer.clearRecording();
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "sequence deleted", .{}) catch "";
}
fn downdelseq(self: *RecorderValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = 0;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "delete sequence", .{}) catch "";
}
fn currentdelseq(self: *RecorderValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt == 1) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "sequence deleted", .{}) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "delete sequence", .{}) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

const RecorderValue = struct {
    recorder: *rcdr.Recorder,
    sequencer: *seq.Sequencer,
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    loaded: bool,
    state: mn.State,
    increment: *const fn (self: *RecorderValue) void,
    decrement: *const fn (self: *RecorderValue) void,
    current: *const fn (self: *RecorderValue) [*c]const u8,
};
pub const RecorderMenuItem = struct {
    label: [*c]const u8,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: []RecorderValue,
    pub fn iMenuItem(self: *RecorderMenuItem) ui.IMenuItem {
        return .{
            .impl = @ptrCast(self),
            .enterFn = enterIImpl,
            .rightFn = rightIImpl,
            .leftFn = leftIImpl,
            .upFn = upIImpl,
            .downFn = downIImpl,
            .currentFn = currentIImpl,
            .labelFn = labelIImpl,
        };
    }
    pub fn enter(self: *RecorderMenuItem) void {
        _ = self;
    }
    pub fn right(self: *RecorderMenuItem) void {
        if (self.selected + 1 < self.menuValues.len) {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
    }
    pub fn left(self: *RecorderMenuItem) void {
        if (self.selected >= 1) {
            self.selected -= 1;
        } else {
            self.selected = self.menuValues.len - 1;
        }
    }
    pub fn up(self: *RecorderMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.increment(menuValueSelf);
    }
    pub fn down(self: *RecorderMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.decrement(menuValueSelf);
    }
    pub fn current(self: *RecorderMenuItem) [*c]const u8 {
        var menuValueSelf = &self.menuValues[self.selected];
        return menuValueSelf.current(menuValueSelf);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        self.enter();
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        const self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

pub fn buildRecorderMenu(alloc: std.mem.Allocator, recorder: *rcdr.Recorder, sequencer: *seq.Sequencer, sampler: *smplr.Sampler) ![]RecorderMenuItem {
    var menuItem: []RecorderMenuItem = try alloc.alloc(RecorderMenuItem, 1);
    var menuValues: []RecorderValue = try alloc.alloc(RecorderValue, 7);
    menuValues[0] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "record sample", .increment = uprecord, .decrement = downrecord, .current = currentrecord, .loaded = false, .state = mn.newState() };
    menuValues[1] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "enable line in", .increment = upLineIn, .decrement = downLineIn, .current = currentLineIn, .loaded = false, .state = mn.newState() };
    menuValues[2] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "record sequence", .increment = uprecseq, .decrement = downrecseq, .current = currentrecseq, .loaded = false, .state = mn.newState() };

    menuValues[3] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "delete sequence", .increment = updelseq, .decrement = downdelseq, .current = currentdelseq, .loaded = false, .state = mn.newState() };
    menuValues[4] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "clicktrack", .increment = upclickTrack, .decrement = downclickTrack, .current = currentclickTrack, .loaded = false, .state = mn.newState() };
    menuValues[5] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "quantize", .increment = upQuant, .decrement = downQuant, .current = currentQuant, .loaded = false, .state = mn.newState() };
    menuValues[6] = RecorderValue{ .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "delete pad", .increment = upDelAll, .decrement = downDelAll, .current = currentDelAll, .loaded = false, .state = mn.newState() };

    menuItem[0].label = "Recorder";
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    menuItem[0].menuValues = menuValues;

    return menuItem;
}

