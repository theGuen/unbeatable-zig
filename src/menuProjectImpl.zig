const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const seq = @import("sequencer.zig");
const std = @import("std");
const smplr = @import("sampler.zig");
const menu = @import("menu.zig");
const settings = @import("settings.zig");

fn leave(self: *ProjectValue) void {
    _ = self;
}
fn upsave(self: *ProjectValue) void {
    smplr.saveSamplerConfig(self.alloc, self.sampler) catch {};
    seq.saveSequence(self.sequencer) catch {};
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = 1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "project saved", .{}) catch "";
}
fn downsave(self: *ProjectValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = 0;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "save project", .{}) catch "";
}
fn currentsave(self: *ProjectValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt == 1) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "project saved", .{}) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "save project", .{}) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

fn upBPM(self: *ProjectValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    settings.bpm = settings.bpm + 1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "BPM {d}", .{settings.bpm}) catch "";
}
fn downBPM(self: *ProjectValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    settings.bpm = settings.bpm - 1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "BPM {d}", .{settings.bpm}) catch "";
}
fn currentBPM(self: *ProjectValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "BPM {d}", .{settings.bpm}) catch "";
    return @ptrCast(self.state.stateValStr);
}
fn leaveBPM(self: *ProjectValue) void {
    std.debug.print("Set BPM\n", .{});
    self.sequencer.setBPM();
}
fn upexit(self: *ProjectValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = self.state.stateValInt + 1;
    if (self.state.stateValInt == 1) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "confirm", .{}) catch "";
    }
    if (self.state.stateValInt == 2) {
        settings.exit = true;
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "leaving", .{}) catch "";
    }
}
fn downexit(self: *ProjectValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt = 0;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "quit", .{}) catch "";
}
fn currentexit(self: *ProjectValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt == 2) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "leaving", .{}) catch "";
    } else if (self.state.stateValInt == 1) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "confirm", .{}) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "quit", .{}) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

const ProjectValue = struct {
    alloc: std.mem.Allocator,
    recorder: *rcdr.Recorder,
    sequencer: *seq.Sequencer,
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    loaded: bool,
    state: menu.State,
    increment: *const fn (self: *ProjectValue) void,
    decrement: *const fn (self: *ProjectValue) void,
    current: *const fn (self: *ProjectValue) [*c]const u8,
    leave: *const fn (self: *ProjectValue) void,
};
pub const ProjectMenuItem = struct {
    label: [*c]const u8,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: []ProjectValue,
    pub fn iMenuItem(self: *ProjectMenuItem) ui.IMenuItem {
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
    pub fn enter(self: *ProjectMenuItem) void {
        _ = self;
    }
    pub fn right(self: *ProjectMenuItem) void {
        if (self.selected + 1 < self.menuValues.len) {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
    }
    pub fn left(self: *ProjectMenuItem) void {
        if (self.selected >= 1) {
            self.selected -= 1;
        } else {
            self.selected = self.menuValues.len - 1;
        }
    }
    pub fn up(self: *ProjectMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.increment(menuValueSelf);
    }
    pub fn down(self: *ProjectMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.decrement(menuValueSelf);
    }
    pub fn leave(self: *ProjectMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.leave(menuValueSelf);
    }
    pub fn current(self: *ProjectMenuItem) [*c]const u8 {
        var menuValueSelf = &self.menuValues[self.selected];
        return menuValueSelf.current(menuValueSelf);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        self.enter();
    }
    pub fn leaveIImpl(self_void: *anyopaque) void {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        self.leave();
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        const self: *ProjectMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

pub fn buildProjectMenu(alloc: std.mem.Allocator, recorder: *rcdr.Recorder, sequencer: *seq.Sequencer, sampler: *smplr.Sampler) ![]ProjectMenuItem {
    var menuItem: []ProjectMenuItem = try alloc.alloc(ProjectMenuItem, 1);
    var menuValues: []ProjectValue = try alloc.alloc(ProjectValue, 3);
    menuValues[0] = ProjectValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "project BPM", .increment = upBPM, .decrement = downBPM, .current = currentBPM, .leave = leaveBPM, .loaded = false, .state = menu.newState() };
    menuValues[1] = ProjectValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "save project", .increment = upsave, .decrement = downsave, .current = currentsave, .leave = leave, .loaded = false, .state = menu.newState() };
    menuValues[2] = ProjectValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = "quit ASD", .increment = upexit, .decrement = downexit, .current = currentexit, .leave = leave, .loaded = false, .state = menu.newState() };

    menuItem[0].label = "Project";
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    menuItem[0].menuValues = menuValues;

    return menuItem;
}
