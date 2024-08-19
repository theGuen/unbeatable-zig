const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const seq = @import("sequencer.zig");
const std = @import("std");
const smplr = @import("sampler.zig");
const menu = @import("menu.zig");
const settings = @import("settings.zig");

fn upstepMode(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.sequencer.setStepMode(true);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "stepMode on", .{}) catch "";
}
fn downstepMode(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt -= 1;
    self.sequencer.setStepMode(false);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "stepMode off", .{}) catch "";
}
fn currentstepMode(self: *StepSequencerValue) [*c]const u8 {
    return @ptrCast(self.state.stateValStr);
}

fn upplayseq(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "playing sequence", .{}) catch "";
    self.state.stateValInt = 1;
    self.sequencer.startPlaying();
}
fn downplayseq(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "play sequence", .{}) catch "";
    self.state.stateValInt = 0;
    self.sequencer.stopPlaying();
}
fn currentplayseq(self: *StepSequencerValue) [*c]const u8 {
    return @ptrCast(self.state.stateValStr);
}

fn upRow(self: *StepSequencerValue) void {
    var tmp = self.label;
    if (self.sequencer.stepMode) {
        _ = self.sequencer.decrementRow();
        tmp = "Quater";
    } else {
        _ = self.sampler.decrementRow();
        tmp = "Row";
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ tmp, self.sequencer.curBar }) catch "";
}
fn downRow(self: *StepSequencerValue) void {
    var tmp = self.label;
    if (self.sequencer.stepMode) {
        _ = self.sequencer.incrementRow();
        tmp = "Quater";
    } else {
        _ = self.sampler.incrementRow();
        tmp = "Row";
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ tmp, self.sequencer.curBar }) catch "";
}
fn currentRow(self: *StepSequencerValue) [*c]const u8 {
    return @ptrCast(self.state.stateValStr);
}

fn upBars(self: *StepSequencerValue) void {
    self.sequencer.numBars += 1;
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sequencer.numBars }) catch "";
}
fn downBars(self: *StepSequencerValue) void {
    if (self.sequencer.numBars >= 2) {
        self.sequencer.numBars -= 1;
    }

    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sequencer.numBars }) catch "";
}
fn currentBars(self: *StepSequencerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sequencer.numBars }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upPattern(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt += 1;
    if (self.state.stateValInt == 16) {
        self.state.stateValInt = 0;
    }
    self.sequencer.setNextPattern(@intCast(self.state.stateValInt));
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
}
fn downPattern(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt -= 1;
    if (self.state.stateValInt == -1) {
        self.state.stateValInt = 15;
    }
    self.sequencer.setNextPattern(@intCast(self.state.stateValInt));
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
}
fn currentPattern(self: *StepSequencerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upNudge(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = self.sequencer.incrementNudge();
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
}
fn downNudge(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = self.sequencer.decrementNudge();
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
}
fn currentNudge(self: *StepSequencerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upFN(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt += 1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
}
fn downFN(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt -= 1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
}
fn currentFN(self: *StepSequencerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

const StepSequencerValue = struct {
    alloc: std.mem.Allocator,
    recorder: *rcdr.Recorder,
    sequencer: *seq.Sequencer,
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    loaded: bool,
    state: menu.State,
    increment: *const fn (self: *StepSequencerValue) void,
    decrement: *const fn (self: *StepSequencerValue) void,
    current: *const fn (self: *StepSequencerValue) [*c]const u8,
};
pub const StepSequencerMenuItem = struct {
    label: [*c]const u8,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: []StepSequencerValue,
    pub fn iMenuItem(self: *StepSequencerMenuItem) ui.IMenuItem {
        return .{
            .impl = @ptrCast(self),
            .enterFn = enterIImpl,
            .leaveFn = leaveIImpl,
            .rightFn = rightIImpl,
            .leftFn = leftIImpl,
            .upFn = upIImpl,
            .downFn = downIImpl,
            .currentFn = currentIImpl,
            .labelFn = labelIImpl,
        };
    }
    pub fn enter(self: *StepSequencerMenuItem) void {
        _ = self;
    }
    pub fn right(self: *StepSequencerMenuItem) void {
        if (self.selected + 1 < self.menuValues.len) {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
    }
    pub fn left(self: *StepSequencerMenuItem) void {
        if (self.selected >= 1) {
            self.selected -= 1;
        } else {
            self.selected = self.menuValues.len - 1;
        }
    }
    pub fn up(self: *StepSequencerMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.increment(menuValueSelf);
    }
    pub fn down(self: *StepSequencerMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.decrement(menuValueSelf);
    }
    pub fn current(self: *StepSequencerMenuItem) [*c]const u8 {
        var menuValueSelf = &self.menuValues[self.selected];
        return menuValueSelf.current(menuValueSelf);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        self.enter();
    }
    pub fn leaveIImpl(self_void: *anyopaque) void {
        _ = self_void;
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        const self: *StepSequencerMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

pub fn buildSequencerMenu(alloc: std.mem.Allocator, recorder: *rcdr.Recorder, sequencer: *seq.Sequencer, sampler: *smplr.Sampler) ![]StepSequencerMenuItem {
    var menuItem: []StepSequencerMenuItem = try alloc.alloc(StepSequencerMenuItem, 1);
    var menuValues: []StepSequencerValue = try alloc.alloc(StepSequencerValue, 6);
    menuValues[0] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "StepSequnce", .increment = upstepMode, .decrement = downstepMode, .current = currentstepMode, .loaded = false, .state = menu.newStateLabeled(@constCast("stepMode off")) };

    menuValues[1] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "play sequence", .increment = upplayseq, .decrement = downplayseq, .current = currentplayseq, .loaded = false, .state = menu.newStateLabeled(@constCast("play sequence")) };
    menuValues[2] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "Pattern", .increment = upPattern, .decrement = downPattern, .current = currentPattern, .loaded = false, .state = menu.newStateLabeled(@constCast("Pattern 0")) };
    menuValues[3] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "max. Bars", .increment = upBars, .decrement = downBars, .current = currentBars, .loaded = false, .state = menu.newStateLabeled(@constCast("max. Bars")) };
    menuValues[4] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "Nudge", .increment = upNudge, .decrement = downNudge, .current = currentNudge, .loaded = false, .state = menu.newStateLabeled(@constCast("Nudge 0")) };
    menuValues[5] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "Quarter", .increment = upRow, .decrement = downRow, .current = currentRow, .loaded = false, .state = menu.newStateLabeled(@constCast("Quarter 0")) };

    menuItem[0].label = "Sequence";
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    menuItem[0].menuValues = menuValues;

    return menuItem;
}
