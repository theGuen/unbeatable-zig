const std = @import("std");
const assert = std.debug.assert;

const ray = @cImport(@cInclude("raylibwrapper.h"));
const sndFile = @import("sndFile.zig");
const sndio = @import("sndio.zig");
const ma = @import("miniaudio.zig");

const mn = @import("menu.zig");
const h = @import("helper.zig");
const smplr = @import("sampler.zig");

var exit = false;
fn shouldExit()bool{
    return exit;
}

var sampler:smplr.Sampler = undefined;
var menu:mn.Menu = undefined;

// TODO: extract a mixer
fn mix()f32{   
    var sample:f32 = 0.0;
    for (sampler.sounds) |*p|{
        sample += p.next();  
    }
    if (sample > 1){
        sample = 1;
    }else if (sample < -1){
        sample = -1;
    }
    return sample*0.8;
}

// TODO:This loop takes 33M in memory???
fn drawWindow(samplers:*smplr.Sampler) !void {
    const screenWidth = 450;
    const screenHeight = 500;

    ray.InitWindow(screenWidth, screenHeight, "Unbeatable - ZIG");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    var buttons : [16]ray.Rectangle= undefined;
    for (buttons) |*b,i|{
        const ix = @intToFloat(f32,10 + (i%4)*10+(i%4)*100);
        const iy = @intToFloat(f32,50 + (i/4)*10+(i/4)*100);
        b.* = ray.Rectangle{ .x=ix, .y=iy, .width=100, .height=100 };
    }

    var btn_colors : [16]ray.Color= undefined;
    for (btn_colors) |*b|{
        b.* = ray.GREEN;
    }
    const keys = [_]c_int{ray.KEY_ONE,ray.KEY_TWO,ray.KEY_THREE,ray.KEY_FOUR,ray.KEY_Q,ray.KEY_W,ray.KEY_E,ray.KEY_R,ray.KEY_A,ray.KEY_S,ray.KEY_D,ray.KEY_F,ray.KEY_Z,ray.KEY_X,ray.KEY_C,ray.KEY_V};
    var textBox = ray.Rectangle{ .x=230, .y=5, .width=210, .height=25 };
    //TODO: use another allocator
    var dta = std.heap.page_allocator.alloc(u8, 256)catch |err| std.debug.panic("write failed: {s}", .{@errorName(err)});
    defer std.heap.page_allocator.free(dta);
    dta[0]=0;
    for (dta[0..255]) |*b| b.* = 0;
    var dt = @ptrCast([*c]u8,dta);
    var letterCount:usize = 0;
    var onText = false;

    while (!ray.WindowShouldClose()) {
        var mousePosition = ray.GetMousePosition();
        for (buttons) |*b,i|{
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)){
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)){
                    samplers.play(i);
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)){
                    samplers.stop(i);
                    btn_colors[i]=ray.GREEN;
                }
            }
        }
        if (ray.IsKeyPressed(ray.KEY_UP)){
            _= menu.prev();
        }
        if (ray.IsKeyPressed(ray.KEY_DOWN)){
            _= menu.next();
        }
        if (ray.IsKeyPressed(ray.KEY_ENTER)){
            _= menu.enter();
        }
        if (ray.IsKeyPressed(ray.KEY_BACKSPACE)){
            _= menu.leave();
        }

        if (ray.WrapCheckCollisionPointRec(&mousePosition, &textBox)){
            onText = true;
            var key = ray.GetCharPressed();
            while (key > 0){
                if ((key >= 32) and(key <= 125) and (letterCount < 255)){
                    dt[letterCount] = @intCast(u8,key);
                    dt[letterCount+1] = 0; // Add null terminator at the end of the string.
                    letterCount+=1;
                }
                key = ray.GetCharPressed();  // Check next character in the queue
            }

            if (ray.IsKeyPressed(ray.KEY_BACKSPACE)){
                letterCount-=1;
                if (letterCount < 0) letterCount = 0;
                dt[letterCount] = 0;
            }
            if (ray.IsKeyPressed(ray.KEY_ENTER)){
                if (dta[0] != 0){
                    if(ma.loadAudioFile(sampler.alloc,dta))|b|{
                        samplers.load(b);
                        for (dta[0..255]) |*x| x.* = 0;
                        letterCount = 0;
                    }else |err|{
                        std.debug.print("ERROR: {s}\n", .{@errorName(err)});
                    }
                }
            }
        }else{
            onText = false;
            for (keys)|k,i|{
                if (ray.IsKeyPressed(k)){
                    samplers.play(i);
                    btn_colors[i]=ray.ORANGE;
                }
                if (ray.IsKeyReleased(k)){
                    samplers.stop(i);
                    btn_colors[i]=ray.GREEN;
                }
            }
            if (ray.IsKeyPressed(ray.KEY_P)){
                samplers.reverseSound();
            }
            if (ray.IsKeyPressed(ray.KEY_L)){
                samplers.loopSound();
            }
        }
        ray.BeginDrawing();
        defer ray.EndDrawing();

        ray.ClearBackground(ray.RAYWHITE);
        ray.DrawText("Enter a sample name to load ->", 10, 10, 8, ray.BLACK);
        ray.DrawText(menu.current(), 10, 20, 8, ray.BLACK);
        
        ray.WrapDrawRectangleRec(&textBox, ray.GRAY);
        if (onText){
             ray.DrawRectangleLines(@floatToInt(c_int,textBox.x), @floatToInt(c_int,textBox.y), @floatToInt(c_int,textBox.width), @floatToInt(c_int,textBox.height), ray.RED);
             ray.DrawText("_", @floatToInt(c_int,textBox.x) + 8 + ray.MeasureText(dt, 15), @floatToInt(c_int,textBox.y) + 10, 15, ray.MAROON);
        }else{
             ray.DrawRectangleLines(@floatToInt(c_int,textBox.x), @floatToInt(c_int,textBox.y), @floatToInt(c_int,textBox.width), @floatToInt(c_int,textBox.height), ray.DARKGRAY);
        }

        ray.DrawText(dt, @floatToInt(c_int,textBox.x) + 5, @floatToInt(c_int,textBox.y) + 8, 15, ray.MAROON);
        for (buttons) |*b,i|{
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
    }
}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer std.debug.assert(!general_purpose_allocator.deinit());

    const alloc = general_purpose_allocator.allocator();

    sampler = smplr.initSampler(alloc); 
    defer sampler.freeAll();
    menu = mn.initMenu(alloc,&sampler);
    defer mn.free(&menu);

    //try loadCmdLineArgSamples(alloc);

    try ma.createLowpass(alloc);
    //TODO:ugly to pass an allocator to free
    defer ma.destroyLowPass(alloc);

    ma.mix = mix;
    ma.exit = shouldExit;
    const audioThread = try std.Thread.spawn(.{}, ma.startAudio, .{});

    try smplr.loadSamplerConfig(alloc,&sampler);
    
    //TODO: just for now.. ui can't load samples
    _ = try std.Thread.spawn(.{}, h.userInput, .{&sampler});
    //Loop forever
    _ = try drawWindow(&sampler);
    exit = true;
    try smplr.saveSamplerConfig(alloc,&sampler);
    audioThread.join();
}