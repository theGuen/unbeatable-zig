const std = @import("std");
const assert = std.debug.assert;

const ray = @cImport(@cInclude("raylibwrapper.h"));
const mn = @import("menu.zig");
const smplr = @import("sampler.zig");
const helper = @import("helper.zig");
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
    const cols = 4;
    var buttons: [cols * 4]ray.Rectangle = undefined;
    for (&buttons, 0..) |*b, i| {
        const ix = @as(f32, @floatFromInt(10 + (i % cols) * 10 + (i % cols) * 100));
        const iy = @as(f32, @floatFromInt(120 + (i / cols) * 10 + (i / cols) * 70));
        b.* = ray.Rectangle{ .x = ix, .y = iy, .width = 100, .height = 70 };
    }

    var btn_colors: [cols * 4]ray.Color = undefined;
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
        const padStr = std.fmt.allocPrint(std.heap.page_allocator, "Pad {d}", .{currentPad}) catch "";
        defer std.heap.page_allocator.free(padStr);
        const padString = @as([*c]u8, @constCast(@ptrCast(padStr)));
        //--------------------------------------------------------------------------------------------------------------------------
        ray.BeginDrawing();
        defer ray.EndDrawing();
        //--------------------------------------------------------------------------------------------------------------------------
        // CALC MENU INPUT
        const vx = ray.GetGamepadAxisMovement(0, ray.GAMEPAD_AXIS_LEFT_X);
        const vy = ray.GetGamepadAxisMovement(0, ray.GAMEPAD_AXIS_LEFT_Y);
        left = vx < 0;
        right = vx > 0;
        up = vy < 0;
        down = vy > 0;

        const but_a = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
        const but_a_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_DOWN);
        const but_b = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT);
        const but_b_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_RIGHT);
        const but_x = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
        const but_x_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_LEFT);
        const but_y = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_UP);
        const but_y_rel = ray.IsGamepadButtonReleased(0, ray.GAMEPAD_BUTTON_RIGHT_FACE_UP);
        const but_start = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_MIDDLE_RIGHT);
        const but_select = ray.IsGamepadButtonPressed(0, ray.GAMEPAD_BUTTON_MIDDLE_LEFT);

        const r: usize = @intCast(samplers.row);
        if (but_a and !but_b) samplers.play(0 + (4 * r), true);
        if (but_a_rel) samplers.stop(0 + (4 * r));

        if (but_b and !but_a) samplers.play(1 + (4 * r), true);
        if (but_b_rel) samplers.stop(1 + (4 * r));

        if (but_x and !but_y) samplers.play(2 + (4 * r), true);
        if (but_x_rel) samplers.stop(2 + (4 * r));

        if (but_y and !but_x) samplers.play(3 + (4 * r), true);
        if (but_y_rel) samplers.stop(3 + (4 * r));

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
        if (but_a and but_b) {
            std.debug.print("Seq prepared\n", .{});
            sequencer.prepared = true;
        }
        if (but_x and but_y) {
            _ = sequencer.stopRecording();
        }
        if (but_x and but_b) {
            _ = sequencer.startPlaying();
        }
        if (but_a and but_y) {
            _ = sequencer.stopPlaying();
        }
        if (sequencer.prepared and (but_a or but_b or but_x or but_y)) {
            _ = sequencer.startRecording();
            sequencer.prepared = false;
        }
        if (ray.IsKeyPressed(ray.KEY_U)) {
            sequencer.prepared = true;
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
                if (sequencer.prepared) {
                    _ = sequencer.startRecording();
                    sequencer.prepared = false;
                }
                samplers.play(i + (4 * r), true);
                btn_colors[i + (4 * r)] = ray.ORANGE;
                currentPad = i + (4 * r);
                sequencer.appendToRecord(currentPad);
            }
            if (ray.IsKeyReleased(k)) {
                samplers.stop(i + (4 * r));
                btn_colors[i + (4 * r)] = ray.GREEN;
            }
        }
        //--------------------------------------------------------------------------------------------------------------------------
        //ray.BeginDrawing();
        //defer ray.EndDrawing();
        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW WAV Display
        ray.ClearBackground(ray.BLACK);
        //ray.DrawRectangle(10, 4, 430, 50, ray.GRAY);
        ray.DrawRectangleLines(10, 4, 430, 50, ray.WHITE);

        for (smplDisp, 0..) |y, x| {
            if (x < sm or x > em) {
                ray.DrawLine(@intCast(x + 10), 29 + y, @intCast(x + 10), 29 - y, ray.DARKGRAY);
            } else {
                ray.DrawLine(@intCast(x + 10), 29 + y, @intCast(x + 10), 29 - y, ray.WHITE);
            }
        }

        const sm_c = @as(c_int, @intCast(sm));
        const em_c = @as(c_int, @intCast(em));
        const ph = @as(c_int, @intFromFloat(cm));
        ray.DrawLine(10 + ph, 4, 10 + ph, 54, ray.RED);
        ray.DrawLine(10 + sm_c, 4, 10 + sm_c, 54, ray.ORANGE);
        ray.DrawLine(10 + em_c, 4, 10 + em_c, 54, ray.ORANGE);

        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW MENU Display
        //ray.DrawRectangle(10, 65, 210, 47, ray.GRAY);
        const mText = menu.current();
        const concatenated = try helper.SubString(std.heap.page_allocator, @constCast(mText), 30);
        defer std.heap.page_allocator.free(concatenated);
        ray.DrawRectangleLines(10, 65, 430, 47, ray.WHITE);
        ray.DrawText(padString, 12, 70, 13, ray.WHITE);
        ray.DrawText(@ptrCast(@constCast(concatenated)), 12, 85, 25, ray.WHITE);
        if (joyStickDetected) {
            ray.DrawCircle(430, 75, 5, ray.GREEN);
        } else {
            ray.DrawCircle(430, 75, 5, ray.RED);
        }

        if (sequencer.recording) {
            ray.DrawCircle(450, 75, 5, ray.RED);
        } else {
            ray.DrawCircle(450, 75, 5, ray.GREEN);
        }
        //--------------------------------------------------------------------------------------------------------------------------
        // DRAW Buttons
        for (&buttons, 0..) |*b, i| {
            ray.WrapDrawRectangleRec(b, btn_colors[i]);
        }
        // DRAW Active Buttons (Gamepi)
        const i: c_int = @intCast(r);
        const ix = @as(c_int, 5);
        const iy = 115 + i * 10 + i * 70;
        ray.DrawRectangleLines(ix, iy, 440, 80, ray.RED);
        //--------------------------------------------------------------------------------------------------------------------------
    }
}

pub const ButtonState = struct {
    up: bool,
    down: bool,
    left: bool,
    right: bool,
    select: bool,
    start: bool,
    a: bool,
    b: bool,
    x: bool,
    y: bool,
};
