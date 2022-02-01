const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");

pub const State = struct {
    stateValInt: i64,
    stateValStr: []u8,
};
fn newState() State {
    var stateStr = std.fmt.allocPrint(std.heap.page_allocator, "not implemented ", .{}) catch "";
    stateStr[stateStr.len - 1] = 0;
    return State{
        .stateValInt = 0,
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
};

fn uplpf(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt += 100;
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn downlpf(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt -= 100;
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn currentlpf(self: *SamplerValue) [*c]const u8 {
    _ = self;
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "cutoff: {d}", .{self.state.stateValInt}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}


fn upreverse(self: *SamplerValue) [*c]const u8 {
    if (!self.sampler.isSoundReverse()) {
        self.sampler.reverseSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn downreverse(self: *SamplerValue) [*c]const u8 {
    if (self.sampler.isSoundReverse()) {
        self.sampler.reverseSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn currentreverse(self: *SamplerValue) [*c]const u8 {
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundReverse()) {
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "reverse: {s}", .{onoff}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}


fn uploop(self: *SamplerValue) [*c]const u8 {
    if (!self.sampler.isSoundLooping()) {
        self.sampler.loopSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn downloop(self: *SamplerValue) [*c]const u8 {
    if (self.sampler.isSoundLooping()) {
        self.sampler.loopSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn currentloop(self: *SamplerValue) [*c]const u8 {
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundLooping()) {
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "loop: {s}", .{onoff}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}


fn upgate(self: *SamplerValue) [*c]const u8 {
    if (!self.sampler.isSoundGated()) {
        self.sampler.gateSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn downgate(self: *SamplerValue) [*c]const u8 {
    if (self.sampler.isSoundGated()) {
        self.sampler.gateSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn currentgate(self: *SamplerValue) [*c]const u8 {
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundGated()) {
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "gate: {s}", .{onoff}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}


fn upmutegroup(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = @intCast(i64, self.sampler.getSoundMutegroup());
    self.state.stateValInt += 1;
    _ = self.sampler.setSoundMutegroup(@intCast(usize, self.state.stateValInt));
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn downmutegroup(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = @intCast(i64, self.sampler.getSoundMutegroup());
    self.state.stateValInt -= 1;
    _ = self.sampler.setSoundMutegroup(@intCast(usize, self.state.stateValInt));
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn currentmutegroup(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = @intCast(i64, self.sampler.getSoundMutegroup());
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "mutegroup: {d}", .{self.state.stateValInt}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}


fn uppitch(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundPitchSemis();
    self.state.stateValInt += 1;
    _ = self.sampler.setSoundPitchSemis(self.state.stateValInt);
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn downpitch(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundPitchSemis();
    self.state.stateValInt -= 1;
    _ = self.sampler.setSoundPitchSemis(self.state.stateValInt);
    return @ptrCast([*c]const u8, self.state.stateValStr);
}
fn currentpitch(self: *SamplerValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundPitchSemis();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "pitch: {d}", .{self.state.stateValInt}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}

const SamplerValue = struct {
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    state: State,
    increment: fn (self: *SamplerValue)[*c]const u8,
    decrement: fn (self: *SamplerValue)[*c]const u8,
    current: fn (self: *SamplerValue)[*c]const u8,
};
pub const SamplerMenuItem = struct {
    label: [*c]const u8,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: []SamplerValue,
    pub fn iMenuItem(self: *SamplerMenuItem) ui.IMenuItem {
        return .{
            .impl = @ptrCast(*anyopaque, self),
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
        _ = menuValueSelf.increment(menuValueSelf);
    }
    pub fn down(self: *SamplerMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        _ = menuValueSelf.decrement(menuValueSelf);
    }
    pub fn current(self: *SamplerMenuItem) [*c]const u8 {
        var menuValueSelf = &self.menuValues[self.selected];
        return menuValueSelf.current(menuValueSelf);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        self.enter();
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        var self = @ptrCast(*SamplerMenuItem, @alignCast(@alignOf(SamplerMenuItem), self_void));
        return self.label;
    }
};

fn buildSamplerMenu(sampler: *smplr.Sampler) ![]SamplerMenuItem {
    var samplerMenuItem:[]SamplerMenuItem = try std.heap.page_allocator.alloc(SamplerMenuItem,1);
    var menuValues:[]SamplerValue = try std.heap.page_allocator.alloc(SamplerValue,5);
    menuValues[0] = SamplerValue{ .sampler = sampler, .label = "reverse", .increment=upreverse, .decrement=downreverse, .current=currentreverse, .state = newState() };
    menuValues[1] = SamplerValue{ .sampler = sampler, .label = "loop", .increment=uploop, .decrement=downloop, .current=currentloop, .state = newState()  };
    menuValues[2] = SamplerValue{ .sampler = sampler, .label = "gate", .increment=upgate, .decrement=downgate, .current=currentgate, .state = newState()  };
    menuValues[3] = SamplerValue{ .sampler = sampler, .label = "mutegroup", .increment=upmutegroup, .decrement=downmutegroup, .current=currentmutegroup, .state = newState()  };
    menuValues[4] = SamplerValue{ .sampler = sampler, .label = "pitch", .increment=uppitch, .decrement=downpitch, .current=currentpitch, .state = newState()  };
    
    samplerMenuItem[0].label = "Sampler";
    samplerMenuItem[0].active = false;
    samplerMenuItem[0].selected = 0;
    samplerMenuItem[0].valueStr = "";
    samplerMenuItem[0].menuValues = menuValues;
    return samplerMenuItem;
}

pub fn initMenu(alloc: std.mem.Allocator, sampler: *smplr.Sampler, gh: []ui.IMenuItem) !Menu {
    var samplerMenu = try buildSamplerMenu(sampler);
    std.debug.print("samplerMenu: {s}\n",.{samplerMenu[0].iMenuItem().label()});
    gh[gh.len-1]=samplerMenu[0].iMenuItem();
    std.debug.print("samplerMenu: {s}\n",.{gh[gh.len-1].label()});
    var menu: Menu = undefined;
    menu.alloc = alloc;
    menu._currentIndex = 0;
    menu.sampler = sampler;
    menu.menuItems = gh;
    return menu;
}
pub fn free(menu: *Menu) void {
    _=menu;
}
