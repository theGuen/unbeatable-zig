const std = @import("std");
const assert = std.debug.assert;

const ray = @cImport(@cInclude("raylibwrapper.h"));
const sndFile = @import("sndFile.zig");
const sndio = @import("sndio.zig");
const ma = @import("miniaudio.zig");

const mn = @import("menu.zig");
const h = @import("helper.zig");
const smplr = @import("sampler.zig");
const rcdr = @import("recorder.zig");


var sampler:smplr.Sampler = undefined;

// TODO: extract a mixer
fn mix()[2]f32{   
    var sample = [2]f32{0,0};
    for (sampler.sounds) |*p|{
        const temp = p.next();  
        sample[0] += temp[0];
        sample[1] += temp[1];
    }
    return sample;
}


// TODO:This loop takes 33M in memory???
fn drawWindow(samplers:*smplr.Sampler,menu:*mn.Menu) !void {
    const screenWidth = 450;
    const screenHeight = 560;    
    var smplDisp:[430]c_int=undefined;

    ray.InitWindow(screenWidth, screenHeight, "ADC - Arcade Drum Center");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    var buttons : [16]ray.Rectangle= undefined;
    for (buttons) |*b,i|{
        const ix = @intToFloat(f32,10 + (i%4)*10+(i%4)*100);
        const iy = @intToFloat(f32,110 + (i/4)*10+(i/4)*100);
        b.* = ray.Rectangle{ .x=ix, .y=iy, .width=100, .height=100 };
    }

    var btn_colors : [16]ray.Color= undefined;
    for (btn_colors) |*b|{
        b.* = ray.GREEN;
    }
    const keys = [_]c_int{ray.KEY_ONE,ray.KEY_TWO,ray.KEY_THREE,ray.KEY_FOUR,ray.KEY_Q,ray.KEY_W,ray.KEY_E,ray.KEY_R,ray.KEY_A,ray.KEY_S,ray.KEY_D,ray.KEY_F,ray.KEY_Z,ray.KEY_X,ray.KEY_C,ray.KEY_V};

    var currentPad:usize = 0;

    while (!ray.WindowShouldClose()) {
        currentPad = sampler.selectedSound;
//--------------------------------------------------------------------------------------------------------------------------
// CALC Sample Display
        var sbuf = sampler.sounds[currentPad].buffer;
        var sm:usize = 0;
        var em:usize = 0;
        var cm:f64 = 0;
        if (sbuf.len > 0){
            const scale = sbuf[0].len/430;
            sm = @floatToInt(usize,sampler.sounds[currentPad].start)/scale;
            em = @floatToInt(usize,sampler.sounds[currentPad].end)/scale;
            cm = sampler.sounds[currentPad].posf/@intToFloat(f64,scale);
        
            for(smplDisp)|*y,i|{
                var val:f32 = 0;
                for(sbuf[0][i*scale..i*scale+scale])|d,j|{
                    const l = std.math.absFloat(d);
                    const r = std.math.absFloat(sbuf[1][j]);
                    val = std.math.max((l+r),val);
                }
                y.*=@floatToInt(c_int,std.math.min(val*25,25));
            }
        }else{
            for(smplDisp)|*y|y.*=0;
        }
//--------------------------------------------------------------------------------------------------------------------------
// CALC MOUSE press pad
        var mousePosition = ray.GetMousePosition();
        for (buttons) |*b,i|{
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)){
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)){
                    samplers.play(i);
                    btn_colors[i]=ray.ORANGE;
                    currentPad = i;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)){
                    samplers.stop(i);
                    btn_colors[i]=ray.GREEN;
                }
            }
        }
//--------------------------------------------------------------------------------------------------------------------------
// CALC MENU Display
        var padStr = std.fmt.allocPrint(std.heap.page_allocator, "Pad {d}", .{currentPad}) catch "";
        defer std.heap.page_allocator.free(padStr);
        const padString = @ptrCast([*c]u8,padStr); 
//--------------------------------------------------------------------------------------------------------------------------
// CALC MENU INPUT
        if (ray.IsKeyPressed(ray.KEY_UP)){
            _= menu.prev();
        }
        if (ray.IsKeyPressed(ray.KEY_DOWN)){
            _= menu.next();
        }
        if (ray.IsKeyPressed(ray.KEY_RIGHT)){
            _= menu.right();
        }
        if (ray.IsKeyPressed(ray.KEY_LEFT)){
            _= menu.left();
        }        
        if (ray.IsKeyPressed(ray.KEY_ENTER)){
            _= menu.enter();
        }
        if (ray.IsKeyPressed(ray.KEY_BACKSPACE)){
            _= menu.leave();
        }
//--------------------------------------------------------------------------------------------------------------------------
// CALC PAD INPUT
        for (keys)|k,i|{
            if (ray.IsKeyPressed(k)){
                samplers.play(i);
                btn_colors[i]=ray.ORANGE;
                currentPad=i;
            }
            if (ray.IsKeyReleased(k)){
                samplers.stop(i);
                btn_colors[i]=ray.GREEN;
            }
        }
//--------------------------------------------------------------------------------------------------------------------------
        ray.BeginDrawing();
        defer ray.EndDrawing();
//--------------------------------------------------------------------------------------------------------------------------
// DRAW WAV Display
        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawRectangle(10, 4, 430, 50, ray.GRAY);
        ray.DrawRectangleLines(10, 4, 430, 50, ray.RED);
        for(smplDisp)|y,x|{
            if (x<sm or x>em){
                ray.DrawLine(@intCast(c_int,x+10),29+y,@intCast(c_int,x+10),29-y,ray.DARKGRAY);
            }else{
                ray.DrawLine(@intCast(c_int,x+10),29+y,@intCast(c_int,x+10),29-y,ray.BLACK);
            }
            
        }
        var ph = @floatToInt(c_int,cm);
        var sm_c = @intCast(c_int,sm);
        var em_c = @intCast(c_int,em);
        ray.DrawLine(10+ph,4,10+ph,54,ray.RED);
        ray.DrawLine(10+sm_c,4,10+sm_c,54,ray.ORANGE);
        ray.DrawLine(10+em_c,4,10+em_c,54,ray.ORANGE);
        //move start
        //ray.CheckCollisionPointLine(mousePosition, ray.Vector2{.x=10+sm_c,.y=4}, ray.Vector2{.x=10+sm_c,.y=54}, 5);
//--------------------------------------------------------------------------------------------------------------------------
// DRAW MENU Display
        ray.DrawRectangle(10, 65, 210, 37, ray.GRAY);
        ray.DrawRectangleLines(10, 65, 210, 37, ray.RED);
        ray.DrawText(padString, 12, 70, 13, ray.BLACK);
        ray.DrawText(menu.current(), 12, 85, 15, ray.MAROON);
//--------------------------------------------------------------------------------------------------------------------------
// DRAW Buttons
        for (buttons) |*b,i|{
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
//--------------------------------------------------------------------------------------------------------------------------
    }
}

fn asyncMain() void {
    var frame = async ma.startAudio();
    // this would be the return value of ma.startAudio()
    const success = await frame;
    _=success catch return {};
}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!general_purpose_allocator.deinit());
    const alloc = general_purpose_allocator.allocator();

    const dir = std.fs.cwd().openDir("c_examples",.{ .iterate = true }) catch return {};
    var walker = dir.iterate();
    while (try walker.next())|entry|{
        if (entry.kind == std.fs.File.Kind.Directory){
            std.debug.print("D {s}\n",.{entry.name});
        }else{
            if (h.StringHasSuffix(entry.name,".wav") or h.StringHasSuffix(entry.name,".mp3")){
                std.debug.print("F {s}\n",.{entry.name});
            }
        }
    }

    sampler = smplr.initSampler(alloc); 
    defer sampler.deinit();
    try smplr.loadSamplerConfig(alloc,&sampler);
    var recorder = rcdr.newRecorder(alloc);

    try h.loadCmdLineArgSamples(alloc,&sampler);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arenaAlloc = arena.allocator();
    var fxMenuItems = try ma.init(alloc,arenaAlloc,mix,&recorder);
    var menu:mn.Menu = try mn.initMenu(arenaAlloc,&sampler,&recorder,fxMenuItems);

    _ = async asyncMain();

    //loop forever
    _ = try drawWindow(&sampler,&menu);

    try smplr.saveSamplerConfig(alloc,&sampler);
    
    resume ma.startAudioFrame;
}