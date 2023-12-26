const std = @import("std");
const assert = std.debug.assert;

const ray = @cImport(@cInclude("raylibwrapper.h"));
const sndFile = @import("sndFile.zig");
//const sndio = @import("sndio.zig");
const ma = @import("miniaudio.zig");
const mah = @cImport(@cInclude("miniaudio.h"));

const mn = @import("menu.zig");
const h = @import("helper.zig");
const smplr = @import("sampler.zig");
const rcdr = @import("recorder.zig");

var sampler: smplr.Sampler = undefined;

// TODO: extract a mixer
fn mix() [2]f32 {
    var sample = [2]f32{ 0, 0 };
    for (&sampler.sounds) |*p| {
        const temp = p.next();
        sample[0] += temp[0];
        sample[1] += temp[1];
    }
    return sample;
}

var music: ray.Music = undefined;

// TODO:This loop takes 33M in memory???
fn drawWindow(samplers: *smplr.Sampler, menu: *mn.Menu) !void {

    const screenWidth = 450;
    const screenHeight = 560;
    const maxDispSamples = 44100 * 5;
    var smplDisp: [430]c_int = undefined;

    ray.InitWindow(screenWidth, screenHeight, "ADC - Arcade Drum Center");
    defer ray.CloseWindow();
    ray.SetTargetFPS(60);

    var buttons: [16]ray.Rectangle = undefined;
    for (&buttons,0..) |*b,i| {
        //const ix = @intToFloat(f32, 10 + (i % 4) * 10 + (i % 4) * 100);
        //const iy = @intToFloat(f32, 110 + (i / 4) * 10 + (i / 4) * 100);
        const ix = @as(f32, @floatFromInt( 10 + (i % 4) * 10 + (i % 4) * 100));
        const iy = @as(f32,@floatFromInt( 110 + (i / 4) * 10 + (i / 4) * 100));
        b.* = ray.Rectangle{ .x = ix, .y = iy, .width = 100, .height = 100 };
    }

    var btn_colors: [16]ray.Color = undefined;
    for (&btn_colors) |*b| {
        b.* = ray.GREEN;
    }
    const keys = [_]c_int{ ray.KEY_ONE, ray.KEY_TWO, ray.KEY_THREE, ray.KEY_FOUR, ray.KEY_Q, ray.KEY_W, ray.KEY_E, ray.KEY_R, ray.KEY_A, ray.KEY_S, ray.KEY_D, ray.KEY_F, ray.KEY_Z, ray.KEY_X, ray.KEY_C, ray.KEY_V };

    var currentPad: usize = 0;

    ray.InitAudioDevice();
    music = ray.LoadMusicStream("project/snd_0.wav");
    ray.PlayMusicStream(music);
    //ray.AttachAudioStreamProcessor(music.stream, callback);
    while (!ray.WindowShouldClose()) {
        ray.UpdateMusicStream(music);
        currentPad = sampler.selectedSound;
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC Sample Display
        const showSample = true;
        var sbuf = sampler.sounds[currentPad].buffer;
        var sm: usize = 0;
        var em: usize = 0;
        var cm: f64 = 0;
        if (sbuf.len > 0 and showSample) {
            const smplCount = @min(sbuf[0].len, maxDispSamples);
            const scale = smplCount / 430;
            const realPos = sampler.sounds[currentPad].posf;

            //const realStart = @floatToInt(usize, sampler.sounds[currentPad].start);
            const realStart = @as(usize,@intFromFloat(sampler.sounds[currentPad].start));
            //const realEnd = @floatToInt(usize, sampler.sounds[currentPad].end);
            const realEnd = @as(usize,@intFromFloat(sampler.sounds[currentPad].end));
            //const tmp = @floatToInt(usize, realPos / @intToFloat(f64, maxDispSamples));
            const tmp = @as(usize,@intFromFloat( realPos / @as(f64,@floatFromInt(maxDispSamples))));

            const offset = tmp * maxDispSamples;
            //cm = (realPos - @intToFloat(f64, offset)) / @intToFloat(f64, scale);
            cm = (realPos - @as(f64,@floatFromInt(offset))) / @as(f64,@floatFromInt(scale));
            if (realStart > offset and realStart < offset + maxDispSamples) {
                sm = (realStart - offset) / scale;
            }
            if (realEnd > offset and realEnd < offset + maxDispSamples) {
                em = (realEnd - offset) / scale;
            } else {
                //TODO: not correct
                em = realEnd;
            }

            for (&smplDisp,0..) |*y, i| {
                var val: f32 = 0;
                const from = @min(sbuf[0].len, offset + i * scale);
                const to = @min(sbuf[0].len, offset + i * scale + scale);
                for (sbuf[0][from..to],0..) |d, j| {
                    const l = std.math.fabs(d);
                    const r = std.math.fabs(sbuf[1][j]);
                    val = @max((l + r), val);
                }
                y.* = @intFromFloat(@min(val * 25, 25));
            }
        } else {
            for (&smplDisp) |*y| y.* = 0;
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MOUSE press pad
        var mousePosition = ray.GetMousePosition();
        for (&buttons,0..) |*b, i| {
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)) {
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                    samplers.play(i);
                    btn_colors[i] = ray.ORANGE;
                    currentPad = i;
                }
                if (ray.IsMouseButtonReleased(ray.MOUSE_BUTTON_LEFT)) {
                    samplers.stop(i);
                    btn_colors[i] = ray.GREEN;
                }
            }
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MENU Display
        var padStr = std.fmt.allocPrint(std.heap.page_allocator, "Pad {d}", .{currentPad}) catch "";
        defer std.heap.page_allocator.free(padStr);
        //const padString = @ptrCast([*c]u8, padStr);
        const padString =@as([*c]u8, @constCast(@ptrCast(padStr)));
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MENU INPUT
        if (ray.IsKeyPressed(ray.KEY_UP)) {
            _ = menu.prev();
        }
        if (ray.IsKeyPressed(ray.KEY_DOWN)) {
            _ = menu.next();
        }
        if (ray.IsKeyPressed(ray.KEY_RIGHT)) {
            _ = menu.right();
        }
        if (ray.IsKeyPressed(ray.KEY_LEFT)) {
            _ = menu.left();
        }
        if (ray.IsKeyPressed(ray.KEY_ENTER)) {
            _ = menu.enter();
        }
        if (ray.IsKeyPressed(ray.KEY_BACKSPACE)) {
            _ = menu.leave();
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC PAD INPUT
        for (keys,0..) |k, i| {
            if (ray.IsKeyPressed(k)) {
                samplers.play(i);
                btn_colors[i] = ray.ORANGE;
                currentPad = i;
            }
            if (ray.IsKeyReleased(k)) {
                samplers.stop(i);
                btn_colors[i] = ray.GREEN;
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

        for (smplDisp,0..) |y, x| {
            if (x < sm or x > em) {
                //ray.DrawLine(@intCast(c_int, x + 10), 29 + y, @intCast(c_int, x + 10), 29 - y, ray.DARKGRAY);
                ray.DrawLine(@intCast(x + 10), 29 + y, @intCast(x + 10), 29 - y, ray.DARKGRAY);
            } else {
                //ray.DrawLine(@intCast(c_int, x + 10), 29 + y, @intCast(c_int, x + 10), 29 - y, ray.BLACK);
                ray.DrawLine(@intCast( x + 10), 29 + y, @intCast(x + 10), 29 - y, ray.BLACK);
            }
        }

        var sm_c = @as(c_int,@intCast(sm));
        var em_c = @as(c_int,@intCast(em));
        //var ph = @floatToInt(c_int, cm);
        var ph = @as(c_int,@intFromFloat(cm));
        ray.DrawLine(10 + ph, 4, 10 + ph, 54, ray.RED);
        ray.DrawLine(10 + sm_c, 4, 10 + sm_c, 54, ray.ORANGE);
        ray.DrawLine(10 + em_c, 4, 10 + em_c, 54, ray.ORANGE);
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
        for (&buttons,0..) |*b, i| {
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
        //--------------------------------------------------------------------------------------------------------------------------
    }
}

//fn asyncMain() void {
//    var frame = async ma.startAudio();
//    // this would be the return value of ma.startAudio()
//    const success = await frame;
//    _ = success catch return {};
//}

pub fn main() !void {
    var general_purpose_allocator = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = general_purpose_allocator.deinit();
    const alloc = general_purpose_allocator.allocator();

    sampler = smplr.initSampler(alloc);
    defer sampler.deinit();
    //try smplr.loadSamplerConfig(alloc, &sampler);
    var recorder = rcdr.newRecorder(alloc);

    try h.loadCmdLineArgSamples(alloc, &sampler);
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const arenaAlloc = arena.allocator();
    var fxMenuItems = try ma.init(alloc, arenaAlloc,mix, &recorder);
    var menu: mn.Menu = try mn.initMenu(alloc, arenaAlloc, &sampler, &recorder, fxMenuItems);
    //_ = async asyncMain();
    //_ = try ma.startAudio();
    
    var ctxConfig: mah.ma_context_config  = mah.ma_context_config_init();
    var  context: mah.ma_context = undefined;
    var pPlaybackInfos : [*c]mah.ma_device_info = undefined;
    var playbackCount: mah.ma_uint32 =0;
    var pCaptureInfos :?*mah.ma_device_info = undefined;
    var captureCount : mah.ma_uint32 =0;

    if (mah.ma_context_init(null, 0, &ctxConfig, &context) != mah.MA_SUCCESS) {
        std.debug.print("ma_context_init failed",.{});
    }
    if (mah.ma_context_get_devices(&context, &pPlaybackInfos, &playbackCount, &pCaptureInfos, &captureCount) != mah.MA_SUCCESS) {
        std.debug.print("ma_context_get_devices failed",.{});
    }

    for (0..playbackCount)|x| {
        std.debug.print("{d}:{s}\n",.{x,pPlaybackInfos[x].name});
    }
    var device = std.mem.zeroes(mah.ma_device);
    var deviceConfig = mah.ma_device_config_init(mah.ma_device_type_playback);
    deviceConfig.playback.pDeviceID = null;
    deviceConfig.playback.format = mah.ma_format_f32;
    deviceConfig.playback.channels = 2;
    deviceConfig.sampleRate = 44100;
    deviceConfig.dataCallback = ma.audio_callback;
    deviceConfig.pUserData = null;
    var r = mah.ma_device_init(&context, &deviceConfig, &device);
    if (r != mah.MA_SUCCESS) {
        std.debug.print("Device init failed:{d}\n", .{r});
        return error.Unknown;
    }
    defer mah.ma_device_uninit(&device);

    r = mah.ma_device_start(&device);
    if (r != mah.MA_SUCCESS) {
        std.debug.print("Could get available frames\n", .{});
        return error.Unknown;
    }
    defer r = mah.ma_device_stop(&device);
    std.debug.print("selected Backend:{d} {s}\n", .{context.backend,mah.ma_get_backend_name(context.backend)});
    std.debug.print("Device Sample rates:{d}\n", .{device.playback.internalSampleRate});
    std.debug.print("Device internal channels:{d}\n", .{device.playback.internalChannels});
    
    //
    //loop forever
    _ = try drawWindow(&sampler, &menu);

    try smplr.saveSamplerConfig(alloc, &sampler);

    //resume ma.startAudioFrame;
}
