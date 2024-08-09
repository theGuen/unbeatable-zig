const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const seq = @import("sequencer.zig");
const std = @import("std");
const smplr = @import("sampler.zig");
const menu = @import("menu.zig");
const settings = @import("settings.zig");

fn upFN(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt+=1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{self.label,self.state.stateValInt}) catch "";
}
fn downFN(self: *StepSequencerValue) void {
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValInt-=1;
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator, "{s} - {d}", .{self.label,self.state.stateValInt}) catch "";
}
fn currentFN(self: *StepSequencerValue) [*c]const u8 {
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
    const label = "Sequence"
    var menuItem: []StepSequencerMenuItem = try alloc.alloc(StepSequencerMenuItem, 1);
    var menuValues: []StepSequencerValue = try alloc.alloc(StepSequencerValue, 1);
    menuValues[0] = StepSequencerValue{ .alloc = alloc, .recorder = recorder, .sequencer = sequencer, .sampler = sampler, .label = label, .increment = upFN, .decrement = downFN, .current = currentFN, .loaded = false, .state = menu.newStateLabeled(@constCast(label)) };

    menuItem[0].label = label;
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    menuItem[0].menuValues = menuValues;

    return menuItem;
}
