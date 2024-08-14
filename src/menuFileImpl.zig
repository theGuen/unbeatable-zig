const std = @import("std");
const smplr = @import("sampler.zig");
const ui = @import("UIGlue.zig");
const rcdr = @import("recorder.zig");
const h = @import("helper.zig");
const ma = @import("miniaudio.zig");
const seq = @import("sequencer.zig");
const mn = @import("menu.zig");
const settings = @import("settings.zig");
//const sndf = @import("sndfile.zig");

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
        self.selected = 0;
        self.menuValues = h.readDirectory(self.alloc, ".") catch return {};
        self.valueStr = self.menuValues.items[self.selected].name;
    }

    pub fn right(self: *FileMenuItem) void {
        const item = self.menuValues.items[self.selected];
        if (item.file) {
            const fileName = h.StringConcat(self.alloc, item.path, item.name) catch return {};
            defer self.alloc.free(fileName);
            const b = ma.loadAudioFile(self.alloc, fileName) catch return {};
            const split = smplr.splitSample(self.alloc, b, b.len) catch return {};
            self.sampler.load(split, self.sampler.selectedSound);
            self.valueStr = self.menuValues.items[self.selected].name;
        } else {
            var asd = self.alloc.alloc(u8, 5) catch return {};
            defer self.alloc.free(asd);
            std.debug.print("dir is {s}\n", .{item.name});
            @memcpy(asd[0..4], ".asd"[0..4]);
            asd[4] = 0;
            if (h.StringHasSuffix(item.name, asd)) {
                std.debug.print("loading: project {s}\n", .{item.name});
                const dirName = h.StringRemoveNullByte(self.alloc, item.name) catch return {};
                //self.alloc.free(settings.currentProj);
                settings.currentProj = @constCast(dirName);
                smplr.loadSamplerConfig(self.alloc, self.sampler, @constCast(dirName)) catch {};
                seq.loadSequence(&seq.sequencer, self.alloc, @constCast(dirName)) catch return {};
                self.valueStr = self.alloc.alloc(u8, 7) catch return {};
                @memcpy(self.valueStr[0..6], "loaded"[0..6]);
                self.valueStr[6] = 0;
            } else {
                const parentDir = h.StringConcat(self.alloc, item.path, item.name) catch return {};
                defer self.alloc.free(parentDir);
                const mnv = h.readDirectory(self.alloc, parentDir) catch return {};
                if (mnv.items.len == 0) {
                    self.valueStr = self.alloc.alloc(u8, 6) catch return {};
                    @memcpy(self.valueStr[0..5], "3mpty"[0..5]);
                    self.valueStr[5] = 0;
                    return;
                }
                self.menuValues.deinit();
                self.menuValues = mnv;
                self.selected = 0;
                self.valueStr = self.menuValues.items[self.selected].name;
            }
        }
    }
    pub fn left(self: *FileMenuItem) void {
        const item = self.menuValues.items[self.selected];
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
        const self: *FileMenuItem = @ptrCast(@alignCast(self_void));
        return self.label;
    }
};

pub fn buildFIleMenu(arena: std.mem.Allocator, alloc: std.mem.Allocator, sampler: *smplr.Sampler) ![]FileMenuItem {
    var menuItem: []FileMenuItem = try arena.alloc(FileMenuItem, 1);
    menuItem[0].alloc = alloc;
    menuItem[0].sampler = sampler;
    menuItem[0].label = "File";
    menuItem[0].active = false;
    menuItem[0].selected = 0;
    menuItem[0].valueStr = "";
    return menuItem;
}
