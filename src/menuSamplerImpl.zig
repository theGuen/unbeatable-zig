const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const h = @import("helper.zig");
const ma = @import("miniaudio.zig");
const seq = @import("sequencer.zig");
const mn = @import("menu.zig");
const settings = @import("settings.zig");

fn upgain(self: *SamplerValue) void {
    self.state.stateValFloat = self.sampler.getSoundGain();
    self.state.stateValFloat = @min(self.state.stateValFloat + 0.1, 1.5);
    _ = self.sampler.setSoundGain(self.state.stateValFloat);
}
fn downgain(self: *SamplerValue) void {
    self.state.stateValFloat = self.sampler.getSoundGain();
    self.state.stateValFloat = @max(self.state.stateValFloat - 0.1, 0);
    _ = self.sampler.setSoundGain(self.state.stateValFloat);
}
fn currentgain(self: *SamplerValue) [*c]const u8 {
    self.state.stateValFloat = self.sampler.getSoundGain();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d:.1}", .{ self.label, self.state.stateValFloat }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upreverse(self: *SamplerValue) void {
    if (!self.sampler.isSoundReverse()) {
        self.sampler.reverseSound();
    }
}
fn downreverse(self: *SamplerValue) void {
    if (self.sampler.isSoundReverse()) {
        self.sampler.reverseSound();
    }
}
fn currentreverse(self: *SamplerValue) [*c]const u8 {
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundReverse()) {
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {s}", .{ self.label, onoff }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn uploop(self: *SamplerValue) void {
    if (!self.sampler.isSoundLooping()) {
        self.sampler.loopSound();
    }
}
fn downloop(self: *SamplerValue) void {
    if (self.sampler.isSoundLooping()) {
        self.sampler.loopSound();
    }
}
fn currentloop(self: *SamplerValue) [*c]const u8 {
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundLooping()) {
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {s}", .{ self.label, onoff }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upgate(self: *SamplerValue) void {
    if (!self.sampler.isSoundGated()) {
        self.sampler.gateSound();
    }
}
fn downgate(self: *SamplerValue) void {
    if (self.sampler.isSoundGated()) {
        self.sampler.gateSound();
    }
}
fn currentgate(self: *SamplerValue) [*c]const u8 {
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundGated()) {
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {s}", .{ self.label, onoff }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upmutegroup(self: *SamplerValue) void {
    self.state.stateValInt = @intCast(self.sampler.getSoundMutegroup());
    self.state.stateValInt += 1;
    _ = self.sampler.setSoundMutegroup(@intCast(self.state.stateValInt));
}
fn downmutegroup(self: *SamplerValue) void {
    self.state.stateValInt = @intCast(self.sampler.getSoundMutegroup());
    self.state.stateValInt -= 1;
    self.state.stateValInt = @max(self.state.stateValInt, 0);
    _ = self.sampler.setSoundMutegroup(@intCast(self.state.stateValInt));
}
fn currentmutegroup(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = @intCast(self.sampler.getSoundMutegroup());
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn uppitch(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundPitchSemis();
    self.state.stateValInt += 1;
    _ = self.sampler.setSoundPitchSemis(self.state.stateValInt);
}
fn downpitch(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundPitchSemis();
    self.state.stateValInt -= 1;
    _ = self.sampler.setSoundPitchSemis(self.state.stateValInt);
}
fn currentpitch(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundPitchSemis();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upstart(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundStart();
    self.state.stateValInt = @min(self.state.stateValInt + 1000, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn downstart(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundStart();
    self.state.stateValInt = @max(self.state.stateValInt - 1000, 0);
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn currentstart(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundStart();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upend(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundEnd();
    self.state.stateValInt = @min(self.state.stateValInt + 1000, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn downend(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundEnd();
    self.state.stateValInt = @max(self.state.stateValInt - 1000, 0);
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn currentend(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundEnd();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upstartlazy(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundCurrentPos();
    self.state.stateValInt = @min(self.state.stateValInt, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn downstartlazy(self: *SamplerValue) void {
    self.state.stateValInt = 0;
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn currentstartlazy(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundStart();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upendlazy(self: *SamplerValue) void {
    self.state.stateValInt = self.sampler.getSoundCurrentPos();

    self.state.stateValInt = @min(self.state.stateValInt, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn downendlazy(self: *SamplerValue) void {
    self.state.stateValInt = @intCast(self.sampler.getSoundSize());
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn currentendlazy(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundEnd();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upmovelazy(self: *SamplerValue) void {
    const s = self.sampler.getSoundStart();
    const e = self.sampler.getSoundEnd();
    const newS = @min(e, @as(i64, @intCast(self.sampler.getSoundSize())));
    const newE = @min(e + (e - s), @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundStart(newS);
    _ = self.sampler.setSoundEnd(newE);
    self.state.stateValInt += 1;
}
fn downmovelazy(self: *SamplerValue) void {
    const s = self.sampler.getSoundStart();
    const e = self.sampler.getSoundEnd();
    const newS = @max(s, 0);
    const newE = @max(s - (e - s), 0);
    _ = self.sampler.setSoundEnd(newS);
    _ = self.sampler.setSoundStart(newE);
    self.state.stateValInt -= 1;
}
fn currentmovelazy(self: *SamplerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upcopy(self: *SamplerValue) void {
    //std.debug.print("self.state.stateValInt {d}\n", .{self.state.stateValInt});
    if (self.state.stateValInt == 1) {
        const src: usize = @intCast(self.state.selection);
        _ = self.sampler.copySound(src, self.sampler.selectedSound);
        self.state.stateValInt = 0;
    } else {
        const s = self.sampler.selectedSound;
        self.state.selection = @intCast(s);
        self.state.stateValInt = 1;
    }
}
fn downcopy(self: *SamplerValue) void {
    self.state.stateValInt = 0;
}
fn currentcopy(self: *SamplerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt > 0) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} from {d} to {d}", .{ self.label, self.state.selection, self.sampler.selectedSound }) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} from {d}", .{ self.label, self.sampler.selectedSound }) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

fn upcrop(self: *SamplerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    _ = self.sampler.cropSound(self.sampler.selectedSound);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "croping", .{}) catch "";
}
fn downcrop(self: *SamplerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "crop sample", .{}) catch "";
}
fn currentcrop(self: *SamplerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "crop sample", .{}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upSlice(self: *SamplerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    _ = self.sampler.sliceSound(self.sampler.selectedSound);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "slicing", .{}) catch "";
}
fn downSlice(self: *SamplerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "slice sample", .{}) catch "";
}
fn currentSlice(self: *SamplerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "slice sample", .{}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upRow(self: *SamplerValue) void {
    _ = self.sampler.decrementRow();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sampler.row }) catch "";
}
fn downRow(self: *SamplerValue) void {
    _ = self.sampler.incrementRow();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sampler.row }) catch "";
}
fn currentRow(self: *SamplerValue) [*c]const u8 {
    return @ptrCast(self.state.stateValStr);
}

const SamplerValue = struct {
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    state: mn.State,
    increment: *const fn (self: *SamplerValue) void,
    decrement: *const fn (self: *SamplerValue) void,
    current: *const fn (self: *SamplerValue) [*c]const u8,
};
pub const SamplerMenuItem = struct {
    label: [*c]const u8,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: []SamplerValue,
    pub fn iMenuItem(self: *SamplerMenuItem) ui.IMenuItem {
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
    pub fn enter(self: *SamplerMenuItem) void {
        _ = self;
    }
    pub fn right(self: *SamplerMenuItem) void {
        if (self.selected + 1 < self.menuValues.len) {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
    }
    pub fn left(self: *SamplerMenuItem) void {
        if (self.selected >= 1) {
            self.selected -= 1;
        } else {
            self.selected = self.menuValues.len - 1;
        }
    }
    pub fn up(self: *SamplerMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.increment(menuValueSelf);
    }
    pub fn down(self: *SamplerMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.decrement(menuValueSelf);
    }
    pub fn current(self: *SamplerMenuItem) [*c]const u8 {
        var menuValueSelf = &self.menuValues[self.selected];
        return menuValueSelf.current(menuValueSelf);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        self.enter();
    }
    pub fn leaveIImpl(self_void: *anyopaque) void {
        _ = self_void;
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        const self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

pub fn buildSamplerMenu(alloc: std.mem.Allocator, sampler: *smplr.Sampler) ![]SamplerMenuItem {
    var samplerMenuItem: []SamplerMenuItem = try alloc.alloc(SamplerMenuItem, 1);
    var menuValues: []SamplerValue = try alloc.alloc(SamplerValue, 15);
    menuValues[0] = SamplerValue{ .sampler = sampler, .label = "gain", .increment = upgain, .decrement = downgain, .current = currentgain, .state = mn.newState() };
    menuValues[1] = SamplerValue{ .sampler = sampler, .label = "reverse", .increment = upreverse, .decrement = downreverse, .current = currentreverse, .state = mn.newState() };
    menuValues[2] = SamplerValue{ .sampler = sampler, .label = "loop", .increment = uploop, .decrement = downloop, .current = currentloop, .state = mn.newState() };
    menuValues[3] = SamplerValue{ .sampler = sampler, .label = "gate", .increment = upgate, .decrement = downgate, .current = currentgate, .state = mn.newState() };
    menuValues[4] = SamplerValue{ .sampler = sampler, .label = "mutegroup", .increment = upmutegroup, .decrement = downmutegroup, .current = currentmutegroup, .state = mn.newState() };
    menuValues[5] = SamplerValue{ .sampler = sampler, .label = "pitch", .increment = uppitch, .decrement = downpitch, .current = currentpitch, .state = mn.newState() };
    //TODO: This goes to the chop menu
    menuValues[6] = SamplerValue{ .sampler = sampler, .label = "start", .increment = upstart, .decrement = downstart, .current = currentstart, .state = mn.newState() };
    menuValues[7] = SamplerValue{ .sampler = sampler, .label = "end", .increment = upend, .decrement = downend, .current = currentend, .state = mn.newState() };
    menuValues[8] = SamplerValue{ .sampler = sampler, .label = "lazystart", .increment = upstartlazy, .decrement = downstartlazy, .current = currentstartlazy, .state = mn.newState() };
    menuValues[9] = SamplerValue{ .sampler = sampler, .label = "lazyend", .increment = upendlazy, .decrement = downendlazy, .current = currentendlazy, .state = mn.newState() };
    menuValues[10] = SamplerValue{ .sampler = sampler, .label = "move", .increment = upmovelazy, .decrement = downmovelazy, .current = currentmovelazy, .state = mn.newState() };
    menuValues[11] = SamplerValue{ .sampler = sampler, .label = "copy", .increment = upcopy, .decrement = downcopy, .current = currentcopy, .state = mn.newState() };
    menuValues[12] = SamplerValue{ .sampler = sampler, .label = "crop", .increment = upcrop, .decrement = downcrop, .current = currentcrop, .state = mn.newState() };
    menuValues[13] = SamplerValue{ .sampler = sampler, .label = "slice", .increment = upSlice, .decrement = downSlice, .current = currentSlice, .state = mn.newState() };
    menuValues[14] = SamplerValue{ .sampler = sampler, .label = "Row", .increment = upRow, .decrement = downRow, .current = currentRow, .state = mn.newStateLabeled(@constCast("Row 0")) };

    samplerMenuItem[0].label = "Sampler";
    samplerMenuItem[0].active = false;
    samplerMenuItem[0].selected = 0;
    samplerMenuItem[0].valueStr = "";
    samplerMenuItem[0].menuValues = menuValues;
    return samplerMenuItem;
}
