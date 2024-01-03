const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const h = @import("helper.zig");
const ma = @import("miniaudio.zig");

pub const State = struct {
    stateValInt: i64,
    stateValFloat: f32,
    stateValStr: []const u8,
};
fn newState() State {
    var stateStr = std.fmt.allocPrint(std.heap.page_allocator, "not implemented ", .{}) catch "";
    //TODO: 0 termination in 0.11
    //stateStr[stateStr.len - 1] = 0;
    return State{
        .stateValInt = 0,
        .stateValFloat = 0,
        .stateValStr = stateStr,
    };
}

pub const Menu = struct {
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
    menuItems: []ui.IMenuItem,
    _currentIndex: usize,
    _active: bool = false,
    pub fn next(self: *Menu) void {
        var item = &self.menuItems[self._currentIndex];
        if (self._active) {
            item.down();
        } else {
            if (self._currentIndex >= self.menuItems.len - 1) {
                self._currentIndex = 0;
            } else {
                self._currentIndex += 1;
            }
        }
    }
    pub fn prev(self: *Menu) void {
        var item = &self.menuItems[self._currentIndex];
        if (self._active) {
            item.up();
        } else {
            if (self._currentIndex <= 0) {
                self._currentIndex = self.menuItems.len - 1;
            } else {
                self._currentIndex -= 1;
            }
        }
    }
    pub fn right(self: *Menu) void {
        var item = &self.menuItems[self._currentIndex];
        if (self._active) {
            item.right();
        }
    }
    pub fn left(self: *Menu) void {
        var item = &self.menuItems[self._currentIndex];
        if (self._active) {
            item.left();
        }
    }
    pub fn enter(self: *Menu) void {
        self._active = true;
        _ = self.menuItems[self._currentIndex].enter();
    }
    pub fn leave(self: *Menu) void {
        self._active = false;
    }
    pub fn current(self: *Menu) [*c]const u8 {
        var item = &self.menuItems[self._currentIndex];
        if (self._active) {
            return item.current();
        }
        return item.label();
    }
    pub fn deinit(self: *Menu) void {
        std.debug.print("Deinit Menu\n", .{});
        for (self.menuItems) |m| {
            std.debug.print("Deinit MenuItem {?}", .{@TypeOf(m)});
            if (@TypeOf(m) == FileMenuItem) {
                std.debug.print("Deinit Filemenu\n", .{});
                m.menuValues.deinit();
            } else {
                std.debug.print("...skip\n", .{});
            }
        }
    }
};

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
    var s = self.sampler.getSoundStart();
    var e = self.sampler.getSoundEnd();
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
    if (self.state.stateValInt > -1) {
        const src: usize = @intCast(self.state.stateValInt);
        _ = self.sampler.copySound(src, self.sampler.selectedSound);
        self.state.stateValInt = -1;
    } else {
        const s = self.sampler.selectedSound;
        self.state.stateValInt = @intCast(s);
    }
}
fn downcopy(self: *SamplerValue) void {
    self.state.stateValInt = -1;
}
fn currentcopy(self: *SamplerValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt > -1) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} from {d} to {d}", .{ self.label, self.state.stateValInt, self.sampler.selectedSound }) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} from {d}", .{ self.label, self.sampler.selectedSound }) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

const SamplerValue = struct {
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    state: State,
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
        var self: *SamplerMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

fn buildSamplerMenu(alloc: std.mem.Allocator, sampler: *smplr.Sampler) ![]SamplerMenuItem {
    var samplerMenuItem: []SamplerMenuItem = try alloc.alloc(SamplerMenuItem, 1);
    var menuValues: []SamplerValue = try alloc.alloc(SamplerValue, 12);
    menuValues[0] = SamplerValue{ .sampler = sampler, .label = "gain", .increment = upgain, .decrement = downgain, .current = currentgain, .state = newState() };
    menuValues[1] = SamplerValue{ .sampler = sampler, .label = "reverse", .increment = upreverse, .decrement = downreverse, .current = currentreverse, .state = newState() };
    menuValues[2] = SamplerValue{ .sampler = sampler, .label = "loop", .increment = uploop, .decrement = downloop, .current = currentloop, .state = newState() };
    menuValues[3] = SamplerValue{ .sampler = sampler, .label = "gate", .increment = upgate, .decrement = downgate, .current = currentgate, .state = newState() };
    menuValues[4] = SamplerValue{ .sampler = sampler, .label = "mutegroup", .increment = upmutegroup, .decrement = downmutegroup, .current = currentmutegroup, .state = newState() };
    menuValues[5] = SamplerValue{ .sampler = sampler, .label = "pitch", .increment = uppitch, .decrement = downpitch, .current = currentpitch, .state = newState() };
    //TODO: This goes to the chop menu
    menuValues[6] = SamplerValue{ .sampler = sampler, .label = "start", .increment = upstart, .decrement = downstart, .current = currentstart, .state = newState() };
    menuValues[7] = SamplerValue{ .sampler = sampler, .label = "end", .increment = upend, .decrement = downend, .current = currentend, .state = newState() };
    menuValues[8] = SamplerValue{ .sampler = sampler, .label = "lazystart", .increment = upstartlazy, .decrement = downstartlazy, .current = currentstartlazy, .state = newState() };
    menuValues[9] = SamplerValue{ .sampler = sampler, .label = "lazyend", .increment = upendlazy, .decrement = downendlazy, .current = currentendlazy, .state = newState() };
    menuValues[10] = SamplerValue{ .sampler = sampler, .label = "move", .increment = upmovelazy, .decrement = downmovelazy, .current = currentmovelazy, .state = newState() };
    menuValues[11] = SamplerValue{ .sampler = sampler, .label = "copy", .increment = upcopy, .decrement = downcopy, .current = currentcopy, .state = newState() };

    samplerMenuItem[0].label = "Sampler";
    samplerMenuItem[0].active = false;
    samplerMenuItem[0].selected = 0;
    samplerMenuItem[0].valueStr = "";
    samplerMenuItem[0].menuValues = menuValues;
    return samplerMenuItem;
}

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
        var recorded = self.recorder.stopRecording();
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

const RecorderValue = struct {
    recorder: *rcdr.Recorder,
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    loaded: bool,
    state: State,
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
        var self: *RecorderMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

fn buildRecorderMenu(alloc: std.mem.Allocator, recorder: *rcdr.Recorder, sampler: *smplr.Sampler) ![]RecorderMenuItem {
    var menuItem: []RecorderMenuItem = try alloc.alloc(RecorderMenuItem, 1);
    var menuValues: []RecorderValue = try alloc.alloc(RecorderValue, 1);
    menuValues[0] = RecorderValue{ .recorder = recorder, .sampler = sampler, .label = "record", .increment = uprecord, .decrement = downrecord, .current = currentrecord, .loaded = false, .state = newState() };

    menuItem[0].label = "Recorder";
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    menuItem[0].menuValues = menuValues;
    return menuItem;
}

pub const FileMenuItem = struct {
    label: [*c]const u8,
    alloc: std.mem.Allocator,
    sampler: *smplr.Sampler,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: std.ArrayList(h.DirEntry),
    pub fn iMenuItem(self: *FileMenuItem) ui.IMenuItem {
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
    pub fn enter(self: *FileMenuItem) void {
        self.menuValues = h.readDirectory(self.alloc, ".") catch return {};
        self.valueStr = self.menuValues.items[self.selected].name;
    }
    pub fn right(self: *FileMenuItem) void {
        var item = self.menuValues.items[self.selected];
        if (item.file) {
            const fileName = h.StringConcat(self.alloc, item.path, item.name) catch return {};
            defer self.alloc.free(fileName);
            var b = ma.loadAudioFile(self.alloc, fileName) catch return {};
            const split = smplr.splitSample(self.alloc, b, b.len) catch return {};
            self.sampler.load(split, self.sampler.selectedSound);
        } else {
            const parentDir = h.StringConcat(self.alloc, item.path, item.name) catch return {};
            defer self.alloc.free(parentDir);
            self.menuValues.deinit();
            self.menuValues = h.readDirectory(self.alloc, parentDir) catch return {};
            self.selected = 0;
        }
        self.valueStr = self.menuValues.items[self.selected].name;
    }
    pub fn left(self: *FileMenuItem) void {
        var item = self.menuValues.items[self.selected];
        const parentDir = h.StringConcat(self.alloc, item.path, "..") catch return {};
        defer self.alloc.free(parentDir);
        self.menuValues.deinit();
        self.menuValues = h.readDirectory(self.alloc, parentDir) catch return {};
        self.selected = 0;
        self.valueStr = self.menuValues.items[self.selected].name;
    }

    pub fn up(self: *FileMenuItem) void {
        if (self.selected + 1 < self.menuValues.items.len) {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
        self.valueStr = self.menuValues.items[self.selected].name;
    }
    pub fn down(self: *FileMenuItem) void {
        if (self.selected >= 1) {
            self.selected -= 1;
        } else {
            self.selected = self.menuValues.items.len - 1;
        }
        self.valueStr = self.menuValues.items[self.selected].name;
    }
    pub fn current(self: *FileMenuItem) [*c]const u8 {
        return @ptrCast(self.valueStr);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        self.enter();
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

fn buildFIleMenu(arena: std.mem.Allocator, alloc: std.mem.Allocator, sampler: *smplr.Sampler) ![]FileMenuItem {
    var menuItem: []FileMenuItem = try arena.alloc(FileMenuItem, 1);
    menuItem[0].alloc = alloc;
    menuItem[0].sampler = sampler;
    menuItem[0].label = "File";
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    return menuItem;
}

pub fn initMenu(notArena: std.mem.Allocator, alloc: std.mem.Allocator, sampler: *smplr.Sampler, recorder: *rcdr.Recorder, otherMenuItems: []ui.MenuItem) !Menu {
    var samplerMenu = try buildSamplerMenu(alloc, sampler);
    var recorderMenu = try buildRecorderMenu(alloc, recorder, sampler);
    var fileMenu = try buildFIleMenu(alloc, notArena, sampler);
    var iMenuItems: []ui.IMenuItem = try alloc.alloc(ui.IMenuItem, otherMenuItems.len + 3);
    iMenuItems[0] = samplerMenu[0].iMenuItem();
    iMenuItems[1] = recorderMenu[0].iMenuItem();
    iMenuItems[2] = fileMenu[0].iMenuItem();
    for (otherMenuItems, 0..) |*omi, i| iMenuItems[i + 3] = omi.iMenuItem();
    var menu: Menu = undefined;
    menu.alloc = alloc;
    menu._currentIndex = 0;
    menu.sampler = sampler;
    menu.menuItems = iMenuItems;
    return menu;
}
