const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const h = @import("helper.zig");
const ma = @import("miniaudio.zig");
const seq = @import("sequencer.zig");
const mimpl = @import("menuImpl.zig");

pub const State = struct {
    stateValInt: i64,
    stateValFloat: f32,
    stateValStr: []const u8,
};
pub fn newState() State {
    const stateStr = std.fmt.allocPrint(std.heap.page_allocator, "not implemented ", .{}) catch "";
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
            if (@TypeOf(m) == mimpl.FileMenuItem) {
                std.debug.print("Deinit Filemenu\n", .{});
                m.menuValues.deinit();
            } else {
                std.debug.print("...skip\n", .{});
            }
        }
    }
};

pub fn initMenu(notArena: std.mem.Allocator, alloc: std.mem.Allocator, sampler: *smplr.Sampler, recorder: *rcdr.Recorder, sequencer: *seq.Sequencer, otherMenuItems: []ui.MenuItem) !Menu {
    var samplerMenu = try mimpl.buildSamplerMenu(alloc, sampler);
    var recorderMenu = try mimpl.buildRecorderMenu(alloc, recorder, sequencer, sampler);
    var fileMenu = try mimpl.buildFIleMenu(alloc, notArena, sampler);
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
