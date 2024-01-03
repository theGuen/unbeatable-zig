const std = @import("std");
const assert = std.debug.assert;

const ray = @cImport(@cInclude("raylibwrapper.h"));
const sndFile = @import("sndFile.zig");
const ma = @import("miniaudio.zig");
const mah = @cImport(@cInclude("miniaudio.h"));

const mn = @import("menu.zig");
const h = @import("helper.zig");
const smplr = @import("sampler.zig");
const rcdr = @import("recorder.zig");
const seq = @import("sequencer.zig");
const settings = @import("settings.zig");

pub fn drawWindow(samplers: *smplr.Sampler, menu: *mn.Menu, sequencer: *seq.Sequencer) !void {
    const screenWidth = 800;
    const screenHeight = 480;
    const maxDispSamples = 44100 * 5;
    var smplDisp: [430]c_int = undefined;

    _ = ray.SetGamepadMappings(@ptrCast(settings.gamePadMapping));
    ray.InitWindow(screenWidth, screenHeight, "ADC - Arcade Drum Center");
    defer ray.CloseWindow();
    ray.SetTargetFPS(30);

    var buttons: [16]ray.Rectangle = undefined;
    for (&buttons, 0..) |*b, i| {
        const ix = @as(f32, @floatFromInt(10 + (i % 4) * 10 + (i % 4) * 100));
        const iy = @as(f32, @floatFromInt(120 + (i / 4) * 10 + (i / 4) * 70));
        b.* = ray.Rectangle{ .x = ix, .y = iy, .width = 100, .height = 70 };
    }

    var btn_colors: [16]ray.Color = undefined;
    for (&btn_colors) |*b| {
        b.* = ray.GREEN;
    }
    const keys = [_]c_int{ ray.KEY_ONE, ray.KEY_TWO, ray.KEY_THREE, ray.KEY_FOUR, ray.KEY_Q, ray.KEY_W, ray.KEY_E, ray.KEY_R, ray.KEY_A, ray.KEY_S, ray.KEY_D, ray.KEY_F, ray.KEY_Z, ray.KEY_X, ray.KEY_C, ray.KEY_V };

    var currentPad: usize = 0;
    var joyStickDetected: bool = false;
    var left = false;
    var right = false;
    var up = false;
    var down = false;
    var left_prev = false;
    var right_prev = false;
    var up_prev = false;
    var down_prev = false;
    var seqRec = false;
    while (!ray.WindowShouldClose()) {
        currentPad = samplers.selectedSound;
        joyStickDetected = ray.IsGamepadAvailable(0);
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC Sample Display
        const showSample = true;
        var sbuf = samplers.sounds[currentPad].buffer;
        var sm: usize = 0;
        var em: usize = 0;
        var cm: f64 = 0;
        if (sbuf.len > 0 and showSample) {
            const smplCount = @min(sbuf[0].len, maxDispSamples);
            const scale = smplCount / 430;
            const realPos = samplers.sounds[currentPad].posf;

            const realStart = @as(usize, @intFromFloat(samplers.sounds[currentPad].start));
            const realEnd = @as(usize, @intFromFloat(samplers.sounds[currentPad].end));
            const tmp = @as(usize, @intFromFloat(realPos / @as(f64, @floatFromInt(maxDispSamples))));

            const offset = tmp * maxDispSamples;
            cm = (realPos - @as(f64, @floatFromInt(offset))) / @as(f64, @floatFromInt(scale));
            if (realStart > offset and realStart < offset + maxDispSamples) {
                sm = (realStart - offset) / scale;
            }
            if (realEnd > offset and realEnd < offset + maxDispSamples) {
                em = (realEnd - offset) / scale;
            } else {
                //TODO: not correct
                em = realEnd;
            }

            for (&smplDisp, 0..) |*y, i| {
                var val: f32 = 0;
                const from = @min(sbuf[0].len, offset + i * scale);
                const to = @min(sbuf[0].len, offset + i * scale + scale);
                for (sbuf[0][from..to], 0..) |d, j| {
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
        for (&buttons, 0..) |*b, i| {
            if (ray.WrapCheckCollisionPointRec(&mousePosition, b)) {
                if (ray.IsMouseButtonPressed(ray.MOUSE_BUTTON_LEFT)) {
                    samplers.play(i, true);
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
        const padString = @as([*c]u8, @constCast(@ptrCast(padStr)));
        //--------------------------------------------------------------------------------------------------------------------------
        ray.BeginDrawing();
        defer ray.EndDrawing();
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MENU INPUT
        var vx = ray.GetGamepadAxisMovement(0, ray.GAMEPAD_AXIS_LEFT_X);
        var vy = ray.GetGamepadAxisMovement(0, ray.GAMEPAD_AXIS_LEFT_Y);
        left = vx < 0;
        right = vx > 0;
        up = vy < 0;
        down = vy > 0;

        var but_a = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
        var but_a_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
        var but_b = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
        var but_b_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
        var but_x = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT);
        var but_x_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT);
        var but_y = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_UP);
        var but_y_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_UP);
        var but_start = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_MIDDLE_RIGHT);
        var but_select = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_MIDDLE_LEFT);

        if (but_a) samplers.play(0, true);
        if (but_a_rel) samplers.stop(0);
        if (but_b) samplers.play(1, true);
        if (but_b_rel) samplers.stop(1);
        if (but_x) samplers.play(2, true);
        if (but_x_rel) samplers.stop(2);
        if (but_y) samplers.play(3, true);
        if (but_y_rel) samplers.stop(3);

        if (ray.IsKeyPressed(ray.KEY_UP) or up and !up_prev) {
            _ = menu.prev();
        }
        if (ray.IsKeyPressed(ray.KEY_DOWN) or down and !down_prev) {
            _ = menu.next();
        }
        if (ray.IsKeyPressed(ray.KEY_RIGHT) or right and !right_prev) {
            _ = menu.right();
        }
        if (ray.IsKeyPressed(ray.KEY_LEFT) or left and !left_prev) {
            _ = menu.left();
        }
        if (ray.IsKeyPressed(ray.KEY_ENTER) or but_select) {
            _ = menu.enter();
        }
        if (ray.IsKeyPressed(ray.KEY_BACKSPACE) or but_start) {
            _ = menu.leave();
        }
        left_prev = left;
        right_prev = right;
        up_prev = up;
        down_prev = down;
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC PAD INPUT
        if (ray.IsKeyPressed(ray.KEY_U)) {
            seqRec = true;
        }
        if (ray.IsKeyPressed(ray.KEY_I)) {
            _ = sequencer.stopRecording();
        }
        if (ray.IsKeyPressed(ray.KEY_O)) {
            _ = sequencer.startPlaying();
        }
        if (ray.IsKeyPressed(ray.KEY_P)) {
            _ = sequencer.stopPlaying();
        }

        for (keys, 0..) |k, i| {
            if (ray.IsKeyPressed(k)) {
                if (seqRec) {
                    _ = sequencer.startRecording();
                    seqRec = false;
                }
                samplers.play(i, true);
                btn_colors[i] = ray.ORANGE;
                currentPad = i;
                sequencer.appendToRecord(currentPad);
            }
            if (ray.IsKeyReleased(k)) {
                samplers.stop(i);
                btn_colors[i] = ray.GREEN;
            }
        }
        //--------------------------------------------------------------------------------------------------------------------------
        //ray.BeginDrawing();
        //defer ray.EndDrawing();
        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW WAV Display
        ray.ClearBackground(ray.DARKGRAY);
        ray.DrawRectangle(10, 4, 430, 50, ray.GRAY);
        ray.DrawRectangleLines(10, 4, 430, 50, ray.BLACK);

        for (smplDisp, 0..) |y, x| {
            if (x < sm or x > em) {
                ray.DrawLine(@intCast(x + 10), 29 + y, @intCast(x + 10), 29 - y, ray.DARKGRAY);
            } else {
                ray.DrawLine(@intCast(x + 10), 29 + y, @intCast(x + 10), 29 - y, ray.BLACK);
            }
        }

        var sm_c = @as(c_int, @intCast(sm));
        var em_c = @as(c_int, @intCast(em));
        var ph = @as(c_int, @intFromFloat(cm));
        ray.DrawLine(10 + ph, 4, 10 + ph, 54, ray.RED);
        ray.DrawLine(10 + sm_c, 4, 10 + sm_c, 54, ray.ORANGE);
        ray.DrawLine(10 + em_c, 4, 10 + em_c, 54, ray.ORANGE);

        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW MENU Display
        ray.DrawRectangle(10, 65, 210, 47, ray.GRAY);
        ray.DrawRectangleLines(10, 65, 210, 47, ray.BLACK);
        ray.DrawText(padString, 12, 70, 13, ray.BLACK);
        ray.DrawText(menu.current(), 12, 85, 25, ray.BLACK);
        if (joyStickDetected) {
            ray.DrawCircle(210, 75, 5, ray.GREEN);
        } else {
            ray.DrawCircle(210, 75, 5, ray.RED);
        }

        if (sequencer.recording) {
            ray.DrawCircle(230, 75, 5, ray.RED);
        } else {
            ray.DrawCircle(230, 75, 5, ray.GREEN);
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW Buttons
        for (&buttons, 0..) |*b, i| {
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
        //--------------------------------------------------------------------------------------------------------------------------
    }
}
