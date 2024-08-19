const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const h = @import("helper.zig");
const ma = @import("miniaudio.zig");
const seq = @import("sequencer.zig");
const mn = @import("menu.zig");
const settings = @import("settings.zig");

fn upstart(self: *ChopValue) void {
    self.state.stateValInt = self.sampler.getSoundStart();
    self.state.stateValInt = @min(self.state.stateValInt + 1000, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn downstart(self: *ChopValue) void {
    self.state.stateValInt = self.sampler.getSoundStart();
    self.state.stateValInt = @max(self.state.stateValInt - 1000, 0);
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn currentstart(self: *ChopValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundStart();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upend(self: *ChopValue) void {
    self.state.stateValInt = self.sampler.getSoundEnd();
    self.state.stateValInt = @min(self.state.stateValInt + 1000, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn downend(self: *ChopValue) void {
    self.state.stateValInt = self.sampler.getSoundEnd();
    self.state.stateValInt = @max(self.state.stateValInt - 1000, 0);
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn currentend(self: *ChopValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundEnd();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upstartlazy(self: *ChopValue) void {
    self.state.stateValInt = self.sampler.getSoundCurrentPos();
    self.state.stateValInt = @min(self.state.stateValInt, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn downstartlazy(self: *ChopValue) void {
    self.state.stateValInt = 0;
    _ = self.sampler.setSoundStart(self.state.stateValInt);
}
fn currentstartlazy(self: *ChopValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundStart();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upendlazy(self: *ChopValue) void {
    self.state.stateValInt = self.sampler.getSoundCurrentPos();

    self.state.stateValInt = @min(self.state.stateValInt, @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn downendlazy(self: *ChopValue) void {
    self.state.stateValInt = @intCast(self.sampler.getSoundSize());
    _ = self.sampler.setSoundEnd(self.state.stateValInt);
}
fn currentendlazy(self: *ChopValue) [*c]const u8 {
    self.state.stateValInt = self.sampler.getSoundEnd();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upmovelazy(self: *ChopValue) void {
    const s = self.sampler.getSoundStart();
    const e = self.sampler.getSoundEnd();
    const newS = @min(e, @as(i64, @intCast(self.sampler.getSoundSize())));
    const newE = @min(e + (e - s), @as(i64, @intCast(self.sampler.getSoundSize())));
    _ = self.sampler.setSoundStart(newS);
    _ = self.sampler.setSoundEnd(newE);
    self.state.stateValInt += 1;
}
fn downmovelazy(self: *ChopValue) void {
    const s = self.sampler.getSoundStart();
    const e = self.sampler.getSoundEnd();
    const newS = @max(s, 0);
    const newE = @max(s - (e - s), 0);
    _ = self.sampler.setSoundEnd(newS);
    _ = self.sampler.setSoundStart(newE);
    self.state.stateValInt -= 1;
}
fn currentmovelazy(self: *ChopValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s}: {d}", .{ self.label, self.state.stateValInt }) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upcopy(self: *ChopValue) void {
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
fn downcopy(self: *ChopValue) void {
    self.state.stateValInt = 0;
}
fn currentcopy(self: *ChopValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    if (self.state.stateValInt > 0) {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} from {d} to {d}", .{ self.label, self.state.selection, self.sampler.selectedSound }) catch "";
    } else {
        self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} from {d}", .{ self.label, self.sampler.selectedSound }) catch "";
    }
    return @ptrCast(self.state.stateValStr);
}

fn upcrop(self: *ChopValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    _ = self.sampler.cropSound(self.sampler.selectedSound);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "croping", .{}) catch "";
}
fn downcrop(self: *ChopValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "crop sample", .{}) catch "";
}
fn currentcrop(self: *ChopValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "crop sample", .{}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upSlice(self: *ChopValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    _ = self.sampler.sliceSound(self.sampler.selectedSound);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "slicing", .{}) catch "";
}
fn downSlice(self: *ChopValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "slice sample", .{}) catch "";
}
fn currentSlice(self: *ChopValue) [*c]const u8 {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "slice sample", .{}) catch "";
    return @ptrCast(self.state.stateValStr);
}

fn upRow(self: *ChopValue) void {
    _ = self.sampler.decrementRow();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sampler.row }) catch "";
}
fn downRow(self: *ChopValue) void {
    _ = self.sampler.incrementRow();
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} {d}", .{ self.label, self.sampler.row }) catch "";
}
fn currentRow(self: *ChopValue) [*c]const u8 {
    return @ptrCast(self.state.stateValStr);
}

const ChopValue = struct {
    sampler: *smplr.Sampler,
    label: [*c]const u8,
    state: mn.State,
    increment: *const fn (self: *ChopValue) void,
    decrement: *const fn (self: *ChopValue) void,
    current: *const fn (self: *ChopValue) [*c]const u8,
};
pub const ChopMenuItem = struct {
    label: [*c]const u8,
    active: bool,
    selected: usize,
    valueStr: []u8,
    menuValues: []ChopValue,
    pub fn iMenuItem(self: *ChopMenuItem) ui.IMenuItem {
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
    pub fn enter(self: *ChopMenuItem) void {
        _ = self;
    }
    pub fn right(self: *ChopMenuItem) void {
        if (self.selected + 1 < self.menuValues.len) {
            self.selected += 1;
        } else {
            self.selected = 0;
        }
    }
    pub fn left(self: *ChopMenuItem) void {
        if (self.selected >= 1) {
            self.selected -= 1;
        } else {
            self.selected = self.menuValues.len - 1;
        }
    }
    pub fn up(self: *ChopMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.increment(menuValueSelf);
    }
    pub fn down(self: *ChopMenuItem) void {
        var menuValueSelf = &self.menuValues[self.selected];
        menuValueSelf.decrement(menuValueSelf);
    }
    pub fn current(self: *ChopMenuItem) [*c]const u8 {
        var menuValueSelf = &self.menuValues[self.selected];
        return menuValueSelf.current(menuValueSelf);
    }

    pub fn enterIImpl(self_void: *anyopaque) void {
        var self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        self.enter();
    }
    pub fn leaveIImpl(self_void: *anyopaque) void {
        _ = self_void;
    }
    pub fn rightIImpl(self_void: *anyopaque) void {
        var self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque) void {
        var self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        self.left();
    }
    pub fn upIImpl(self_void: *anyopaque) void {
        var self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque) void {
        var self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque) [*c]const u8 {
        var self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque) [*c]const u8 {
        const self: *ChopMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

pub fn buildChopMenu(alloc: std.mem.Allocator, sampler: *smplr.Sampler) ![]ChopMenuItem {
    var chopMenuItem: []ChopMenuItem = try alloc.alloc(ChopMenuItem, 1);
    var menuValues: []ChopValue = try alloc.alloc(ChopValue, 9);
    menuValues[0] = ChopValue{ .sampler = sampler, .label = "start", .increment = upstart, .decrement = downstart, .current = currentstart, .state = mn.newState() };
    menuValues[1] = ChopValue{ .sampler = sampler, .label = "end", .increment = upend, .decrement = downend, .current = currentend, .state = mn.newState() };
    menuValues[2] = ChopValue{ .sampler = sampler, .label = "lazystart", .increment = upstartlazy, .decrement = downstartlazy, .current = currentstartlazy, .state = mn.newState() };
    menuValues[3] = ChopValue{ .sampler = sampler, .label = "lazyend", .increment = upendlazy, .decrement = downendlazy, .current = currentendlazy, .state = mn.newState() };
    menuValues[4] = ChopValue{ .sampler = sampler, .label = "move", .increment = upmovelazy, .decrement = downmovelazy, .current = currentmovelazy, .state = mn.newState() };
    menuValues[5] = ChopValue{ .sampler = sampler, .label = "copy", .increment = upcopy, .decrement = downcopy, .current = currentcopy, .state = mn.newState() };
    menuValues[6] = ChopValue{ .sampler = sampler, .label = "crop", .increment = upcrop, .decrement = downcrop, .current = currentcrop, .state = mn.newState() };
    menuValues[7] = ChopValue{ .sampler = sampler, .label = "slice", .increment = upSlice, .decrement = downSlice, .current = currentSlice, .state = mn.newState() };
    menuValues[8] = ChopValue{ .sampler = sampler, .label = "Row", .increment = upRow, .decrement = downRow, .current = currentRow, .state = mn.newStateLabeled(@constCast("Row 0")) };

    chopMenuItem[0].label = "Chop";
    chopMenuItem[0].active = false;
    chopMenuItem[0].selected = 0;
    chopMenuItem[0].valueStr = "";
    chopMenuItem[0].menuValues = menuValues;
    return chopMenuItem;
}
