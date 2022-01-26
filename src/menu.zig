const std = @import("std");
const smplr = @import("sampler.zig");

const Item = struct{
    sampler:*smplr.Sampler,
    name: [*c]const u8,
    active: bool,
    state: State,
    current: fn (self: *Item)[*c]const u8,
    enter: fn (self: *Item)[*c]const u8,
    up: fn (self: *Item)[*c]const u8,
    down: fn (self: *Item)[*c]const u8,
};

pub const State = struct{
    stateValInt:i64,
    stateValStr:[]u8,
};
fn newState()State{
    var stateStr = std.fmt.allocPrint(std.heap.page_allocator,"not implemented ",.{}) catch "";
    stateStr[stateStr.len-1]=0;
    return State{
        .stateValInt = 0,
        .stateValStr = stateStr,
    };
}

pub const Menu = struct{
    alloc: std.mem.Allocator,
    sampler:*smplr.Sampler,
    items:[6]Item,
    _currentIndex:usize,
    pub fn next(self: *Menu)[*c]const u8{
        var item = &self.items[self._currentIndex];
        if (item.active){
            return item.down(item);
        }else{
            if (self._currentIndex == self.items.len-1){
                self._currentIndex = 0;
            }else{
                self._currentIndex += 1;
            }
            return item.name;
        }
    }
    pub fn prev(self: *Menu)[*c]const u8{
        var item = &self.items[self._currentIndex];
        if (item.active){
            return item.up(item);
        }else{
            if (self._currentIndex == 0){
                self._currentIndex = self.items.len-1;
            }else{
                self._currentIndex -= 1;
            }
            return item.name;
        }
    }
    pub fn enter(self: *Menu)[*c]const u8{
        var item = &self.items[self._currentIndex];
        item.active = true;
        return item.enter(item);
    }
    pub fn leave(self: *Menu)[*c]const u8{
        var item = &self.items[self._currentIndex];
        item.active = false;
        return item.name;
    }
    pub fn current(self: *Menu)[*c]const u8{
        var item = &self.items[self._currentIndex];
        if (item.active){
            return item.current(item);
        }
        return item.name;
    }
};

fn dummy(self: *Item)[*c]const u8{
    return @ptrCast([*c]const u8, self.state.stateValStr);
}

fn enterlpf(self: *Item)[*c]const u8{
    return currentlpf(self);
}
fn uplpf(self: *Item)[*c]const u8{
    self.state.stateValInt +=100;
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn downlpf(self: *Item)[*c]const u8{
    self.state.stateValInt -=100;
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn currentlpf(self: *Item)[*c]const u8{
    _ = self;
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator,"cutoff: {d}",.{self.state.stateValInt}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}

fn enterreverse(self: *Item)[*c]const u8{
    return currentreverse(self);
}
fn upreverse(self: *Item)[*c]const u8{
    if (!self.sampler.isSoundReverse()){
        self.sampler.reverseSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn downreverse(self: *Item)[*c]const u8{
    if (self.sampler.isSoundReverse()){
        self.sampler.reverseSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn currentreverse(self: *Item)[*c]const u8{
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundReverse()){
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator,"reverse: {s}",.{onoff}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}

fn enterloop(self: *Item)[*c]const u8{
    return currentloop(self);
}
fn uploop(self: *Item)[*c]const u8{
    if (!self.sampler.isSoundLooping()){
        self.sampler.loopSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn downloop(self: *Item)[*c]const u8{
    if (self.sampler.isSoundLooping()){
        self.sampler.loopSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn currentloop(self: *Item)[*c]const u8{
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundLooping()){
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator,"loop: {s}",.{onoff}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}

fn entergate(self: *Item)[*c]const u8{
    return currentgate(self);
}
fn upgate(self: *Item)[*c]const u8{
    if (!self.sampler.isSoundGated()){
        self.sampler.gateSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn downgate(self: *Item)[*c]const u8{
    if (self.sampler.isSoundGated()){
        self.sampler.gateSound();
    }
    return @ptrCast([*c]const u8, self.state.stateValStr );
}
fn currentgate(self: *Item)[*c]const u8{
    var onoff = "OFF";
    self.state.stateValInt = -1;
    if (self.sampler.isSoundGated()){
        onoff = "ON ";
        self.state.stateValInt = 1;
    }
    std.heap.page_allocator.free(self.state.stateValStr);
    self.state.stateValStr = std.fmt.allocPrint(std.heap.page_allocator,"gate: {s}",.{onoff}) catch "";
    return @ptrCast([*c]const u8, self.state.stateValStr);
}


pub fn initMenu(alloc: std.mem.Allocator,sampler:*smplr.Sampler)Menu{
    var menu:Menu = undefined;
    menu.alloc = alloc;
    menu._currentIndex = 0;
    menu.sampler = sampler;
    menu.items[0]=Item{
        .sampler = sampler,
        .name = @ptrCast([*c]const u8, "load Project"),
        .active = false,
        .state = newState(),
        .enter = dummy,
        .up = dummy,
        .down = dummy,
        .current = dummy,
    };
    menu.items[1]=Item{
        .sampler = sampler,
        .name = @ptrCast([*c]const u8, "save Project"),
        .active = false,
        .state = newState(),
        .enter = dummy,
        .up = dummy,
        .down = dummy,
        .current = dummy,
    };
    menu.items[2]=Item{
        .sampler = sampler,
        .name = @ptrCast([*c]const u8, "lpf"),
        .active = false,
        .state = newState(),
        .enter = enterlpf,
        .up = uplpf,
        .down = downlpf,
        .current = currentlpf,
    };
    menu.items[3]=Item{
        .sampler = sampler,
        .name = @ptrCast([*c]const u8, "reverse"),
        .active = false,
        .state = newState(),
        .enter = enterreverse,
        .up = upreverse,
        .down = downreverse,
        .current = currentreverse,
    };
    menu.items[4]=Item{
        .sampler = sampler,
        .name = @ptrCast([*c]const u8, "loop"),
        .active = false,
        .state = newState(),
        .enter = enterloop,
        .up = uploop,
        .down = downloop,
        .current = currentloop,
    };
    menu.items[5]=Item{
        .sampler = sampler,
        .name = @ptrCast([*c]const u8, "gate"),
        .active = false,
        .state = newState(),
        .enter = entergate,
        .up = upgate,
        .down = downgate,
        .current = currentgate,
    };
    return menu;
}
pub fn free(menu: *Menu)void {
    for (menu.items)|*item|{
        std.heap.page_allocator.free(item.state.stateValStr);
    }
}