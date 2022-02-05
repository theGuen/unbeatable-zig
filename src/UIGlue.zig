const std = @import("std");

pub const openHorizontalBoxFun = ?fn (?*anyopaque, [*c]const u8) callconv(.C) void;
pub const openVerticalBoxFun = ?fn (?*anyopaque, [*c]const u8) callconv(.C) void;
pub const addCheckButtonFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32) callconv(.C) void;
pub const closeBoxFun = ?fn (?*anyopaque) callconv(.C) void;
pub const addNumEntryFun = ?fn (?*anyopaque, [*c]const u8, [*c]f32, f32, f32, f32, f32) callconv(.C) void;

fn openHorizontalBoxImpl(ui:?*anyopaque, label:[*c]const u8) callconv(.C) void{
    _=ui;
    _=label;
    var gh = @ptrCast(*GroupHolder, @alignCast(@alignOf(GroupHolder), ui));
    if(gh.label[0]==0){
        gh.label = label;
    }
    gh.openBoxes +=1;
    gh.items[gh.count].label = label;
    std.debug.print("openHorizontalBoxImpl:{s}\n",.{label});
}
fn openVerticalBoxImpl(ui:?*anyopaque, label:[*c]const u8) callconv(.C) void{
    _=ui;
    _=label;
    var gh = @ptrCast(*GroupHolder, @alignCast(@alignOf(GroupHolder), ui));
    gh.openBoxes +=1;
    gh.items[gh.count].label = label;
    std.debug.print("openVerticalBoxImpl:{s}\n",.{label});
}
fn closeBoxImpl(ui:?*anyopaque) callconv(.C) void{
    _=ui;  
    var gh = @ptrCast(*GroupHolder, @alignCast(@alignOf(GroupHolder), ui));
    gh.openBoxes -=1;
    if (gh.openBoxes>0){
        gh.count+=1;
        std.debug.print("closeBoxImpl\n",.{});
    }
}
fn addCheckButtonImpl(ui:?*anyopaque, label:[*c]const u8, valuePtr:[*c]f32) callconv(.C) void{
    var tmp = @ptrCast(*GroupHolder, @alignCast(@alignOf(GroupHolder), ui));
    var ig:*ItemGroup=&tmp.items[tmp.count];
    ig.items[ig.count]=MItem{
        .label=label,
        .toggle=true,
        .valuePtr=valuePtr,
        .value = 0,
        .valueStr = 0,
        .default=0,
        .min=0,
        .max=1,
        .inc=1,
    };
    ig.count +=1;
}
fn addNumEntryImpl(ui:?*anyopaque, label:[*c]const u8, valuePtr:[*c]f32, default:f32, min:f32, max:f32, inc:f32) callconv(.C) void{
    var tmp = @ptrCast(*GroupHolder, @alignCast(@alignOf(GroupHolder), ui));
    var ig:*ItemGroup=&tmp.items[tmp.count];
    ig.items[ig.count]=MItem{
        .label=label,
        .toggle=false,
        .valuePtr=valuePtr,
        .value = 0,
        .valueStr = 0,
        .default=default,
        .min=min,
        .max=max,
        .inc=inc,
    };
    ig.count +=1;
}

pub const UIGlue = extern struct {
    uiInterface: ?*anyopaque,
    //openTabBox: openTabBoxFun,
    openHorizontalBox: openHorizontalBoxFun,
    openVerticalBox: openVerticalBoxFun,
    closeBox: closeBoxFun,
    //addButton: addButtonFun,
    addCheckButton: addCheckButtonFun,
    addNumEntry: addNumEntryFun
};

pub fn newUIGlue()!*UIGlue{
    var retval:UIGlue = undefined;
    var groupholder:GroupHolder = undefined;
    groupholder.label = @ptrCast([*c]const u8, "");
    for (groupholder.items)|*ig|{
        ig.count=0;
        ig.selected=0;
    }
    groupholder.openBoxes=0;
    groupholder.count=0;
    retval.uiInterface=@ptrCast(*anyopaque, &groupholder);
    retval.openHorizontalBox=openHorizontalBoxImpl;
    retval.openVerticalBox= openVerticalBoxImpl;
    retval.closeBox= closeBoxImpl;
    retval.addCheckButton= addCheckButtonImpl;
    retval.addNumEntry= addNumEntryImpl;
    return &retval;
}

pub const MItem=extern struct{
    label:[*c]const u8,
    toggle:bool,
    valuePtr:[*c]f32,
    value:f32,
    valueStr:[*c] u8,
    default:f32,
    min:f32,
    max:f32,
    inc:f32,
};
pub const ItemGroup = extern struct{
    label:[*c]const u8,
    active:bool,
    selected:usize,
    count:usize,
    items:[8]MItem,
};
pub const GroupHolder = extern struct{
    label:[*c]const u8,
    openBoxes:usize,
    count:usize,
    items:[16]ItemGroup
};

pub fn MenuItemsFromUIGlue(alloc: std.mem.Allocator,uiGlue:*UIGlue)![]MenuItem{
    var tmp = @ptrCast(*GroupHolder, @alignCast(@alignOf(GroupHolder), uiGlue.*.uiInterface));
    const gCount = tmp.count;
    var items:[]MenuItem = try alloc.alloc(MenuItem,gCount);  
    for(items)|*item,i|{
        item.label = tmp.items[i].label;
        item.valueStr = "";
        item.selected = 0;
        const iCount = tmp.items[i].count;
        item.menuValues = try alloc.alloc(MenuValue,iCount);
        for(item.menuValues)|*value,j|{
            value.label=tmp.items[i].items[j].label;
            value.toggle=tmp.items[i].items[j].toggle;
            value.value=tmp.items[i].items[j].value;
            value.valuePtr=tmp.items[i].items[j].valuePtr;
            value.default=tmp.items[i].items[j].default;
            value.min=tmp.items[i].items[j].min;
            value.max=tmp.items[i].items[j].max;
            value.inc=tmp.items[i].items[j].inc;
        }
    }
    return items;
}

pub const MenuValue=struct{
    label:[*c]const u8,
    toggle:bool,
    value:f32,
    valuePtr:[*c]f32,
    default:f32,
    min:f32,
    max:f32,
    inc:f32, 
    fn increment(self:*MenuValue)void{
        if(self.value + self.inc < self.max){
            self.value += self.inc;          
        }else{
            self.value =self.max;
        }
        self.valuePtr.* = self.value;
    }
    fn decrement(self:*MenuValue)void{
        if(self.value - self.inc > self.min){
            self.value -= self.inc;
        }else{
            self.value =self.min;
        }
        self.valuePtr.* = self.value;
    } 
};

pub const MenuItem = struct{
    label:[*c]const u8,
    active:bool,
    selected:usize,
    valueStr:[]u8,
    menuValues:[]MenuValue,
    pub fn iMenuItem(self: *MenuItem) IMenuItem {
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
    pub fn enter(self: *MenuItem)void{
        _ = self;
    }
    pub fn right(self:*MenuItem)void{
        if(self.selected + 1 < self.menuValues.len){
            self.selected += 1;
        }else{
            self.selected = 0;
        }
    }
    pub fn left(self:*MenuItem)void{
        if(self.selected >= 1){
            self.selected -= 1;
        }else{
            self.selected =self.menuValues.len-1;
        }
    } 
    pub fn up(self: *MenuItem)void{
        self.menuValues[self.selected].increment();
    }
    pub fn down(self: *MenuItem)void{
        self.menuValues[self.selected].decrement();
    }
    pub fn current(self: *MenuItem)[*c]const u8{
        std.heap.page_allocator.free(self.valueStr);
        self.valueStr = std.fmt.allocPrint(std.heap.page_allocator,"{s} {s}: {d:.2}",.{self.label,self.menuValues[self.selected].label,self.menuValues[self.selected].valuePtr.*}) catch "";
        return @ptrCast([*c]const u8, self.valueStr);
    } 

    pub fn enterIImpl(self_void: *anyopaque)void{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        self.enter();
    }
    pub fn rightIImpl(self_void: *anyopaque)void{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        self.right();
    }
    pub fn leftIImpl(self_void: *anyopaque)void{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        self.left();
    } 
    pub fn upIImpl(self_void: *anyopaque)void{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        self.up();
    }
    pub fn downIImpl(self_void: *anyopaque)void{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        self.down();
    }
    pub fn currentIImpl(self_void: *anyopaque)[*c]const u8{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        return self.current();
    }
    pub fn labelIImpl(self_void: *anyopaque)[*c]const u8{
        var self = @ptrCast(*MenuItem, @alignCast(@alignOf(MenuItem), self_void));
        return self.label;
    }   
};

pub const IMenuItem = struct {
    impl: *anyopaque,
    enterFn: fn(*anyopaque)void,
    rightFn: fn(*anyopaque)void,
    leftFn: fn(*anyopaque)void,
    upFn: fn(*anyopaque)void,
    downFn: fn(*anyopaque)void,
    currentFn: fn(*anyopaque)[*c]const u8,
    labelFn: fn(*anyopaque)[*c]const u8,
    pub fn enter(iface: *const IMenuItem)void{
        return iface.enterFn(iface.impl);
    }
    pub fn right(iface: *const IMenuItem)void{
        return iface.rightFn(iface.impl);
    }
    pub fn left(iface: *const IMenuItem)void{
        return iface.leftFn(iface.impl);
    }
    pub fn up(iface: *const IMenuItem)void{
        return iface.upFn(iface.impl);
    }
    pub fn down(iface: *const IMenuItem)void{
        return iface.downFn(iface.impl);
    } 
    pub fn current(iface: *const IMenuItem)[*c]const u8{
        return iface.currentFn(iface.impl);
    } 
    pub fn label(iface: *const IMenuItem)[*c]const u8{
        return iface.labelFn(iface.impl);
    } 
};
